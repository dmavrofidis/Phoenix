import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
import test from "node:test";

const templateRoot = new URL("../", import.meta.url);

async function render(pathname = "/") {
  const workerUrl = new URL("../dist/server/index.js", import.meta.url);
  workerUrl.searchParams.set("test", `${process.pid}-${Date.now()}`);
  const { default: worker } = await import(workerUrl.href);

  return worker.fetch(
    new Request(`http://localhost${pathname}`, {
      headers: { accept: "text/html" },
    }),
    {
      ASSETS: {
        fetch: async () => new Response("Not found", { status: 404 }),
      },
    },
    {
      waitUntil() {},
      passThroughOnException() {},
    },
  );
}

test("server-renders the Phoenix iPhone installer", async () => {
  const response = await render();
  assert.equal(response.status, 200);
  assert.match(response.headers.get("content-type") ?? "", /^text\/html\b/i);

  const html = await response.text();
  assert.match(html, /<title>Phoenix/);
  assert.match(html, /Η εφαρμογή σου είναι έτοιμη/);
  assert.match(html, /href="\/app\/index\.html"/);
  assert.match(html, /Προσθήκη στην οθόνη Αφετηρίας/);
  assert.match(html, /Χωρίς tracking/);
  assert.doesNotMatch(html, /Codex|codex-preview|react-loading-skeleton/);
});

test("server-renders the public privacy and support pages", async () => {
  const [privacyResponse, supportResponse] = await Promise.all([
    render("/privacy"),
    render("/support"),
  ]);

  assert.equal(privacyResponse.status, 200);
  assert.equal(supportResponse.status, 200);

  const [privacyHtml, supportHtml] = await Promise.all([
    privacyResponse.text(),
    supportResponse.text(),
  ]);
  assert.match(privacyHtml, /Πολιτική Απορρήτου/);
  assert.match(privacyHtml, /English/);
  assert.match(privacyHtml, /Deutsch/);
  assert.match(privacyHtml, /31 Αυγούστου 2026/);
  assert.match(supportHtml, /Είμαστε εδώ για να βοηθήσουμε/);
  assert.match(supportHtml, /github\.com\/dmavrofidis\/Phoenix\/issues/);
  assert.match(supportHtml, /Μεταφορά σε άλλη συσκευή/);
});

test("bundles the Phoenix offline PWA shell", async () => {
  const [manifestRaw, index, serviceWorker] = await Promise.all([
    readFile(new URL("../public/app/manifest.json", import.meta.url), "utf8"),
    readFile(new URL("../public/app/index.html", import.meta.url), "utf8"),
    readFile(
      new URL("../public/app/phoenix-service-worker.js", import.meta.url),
      "utf8",
    ),
  ]);

  const manifest = JSON.parse(manifestRaw);
  assert.equal(manifest.name.startsWith("Phoenix"), true);
  assert.equal(manifest.display, "standalone");
  assert.equal(manifest.start_url, "./?pwa=1");
  assert.match(index, /<base href="\/app\/">/);
  assert.match(index, /apple-mobile-web-app-title/);
  assert.match(serviceWorker, /phoenix-offline-/);
  await access(new URL("../public/app/icons/Icon-192.png", import.meta.url));
  await access(new URL("../public/app/main.dart.js", import.meta.url));
  await assert.rejects(
    access(new URL("app/_sites-preview/SkeletonPreview.tsx", templateRoot)),
  );
});
