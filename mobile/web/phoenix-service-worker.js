const CACHE_VERSION = "phoenix-offline-v308";
const APP_SHELL = [
  "./",
  "./index.html",
  "./manifest.json",
  "./flutter.js",
  "./flutter_bootstrap.js",
  "./main.dart.js",
  "./pwa-install.js",
  "./sqlite3.wasm",
  "./drift_worker.dart.js",
  "./assets/AssetManifest.bin.json",
  "./assets/FontManifest.json",
  "./assets/fonts/MaterialIcons-Regular.otf",
  "./icons/Icon-192.png",
  "./icons/Icon-512.png",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_VERSION).then((cache) => cache.addAll(APP_SHELL)),
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter((key) => key.startsWith("phoenix-offline-"))
            .filter((key) => key !== CACHE_VERSION)
            .map((key) => caches.delete(key)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET") return;

  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          void caches
            .open(CACHE_VERSION)
            .then((cache) => cache.put("./index.html", copy));
          return response;
        })
        .catch(() =>
          caches
            .match(request)
            .then((cached) => cached || caches.match("./index.html")),
        ),
    );
    return;
  }

  event.respondWith(
    caches.match(request).then((cached) => {
      const refresh = fetch(request)
        .then((response) => {
          if (response.ok || response.type === "opaque") {
            const copy = response.clone();
            void caches
              .open(CACHE_VERSION)
              .then((cache) => cache.put(request, copy));
          }
          return response;
        })
        .catch(() => cached);
      return cached || refresh;
    }),
  );
});

self.addEventListener("sync", (event) => {
  if (event.tag !== "phoenix-local-maintenance") return;
  event.waitUntil(
    self.clients.matchAll({ type: "window" }).then((clients) => {
      for (const client of clients) {
        client.postMessage({ type: "PHOENIX_LOCAL_MAINTENANCE" });
      }
    }),
  );
});

self.addEventListener("message", (event) => {
  if (event.data?.type !== "PHOENIX_CACHE_STATUS") return;
  event.waitUntil(
    caches.open(CACHE_VERSION).then(async (cache) => {
      const keys = await cache.keys();
      event.source?.postMessage({
        type: "PHOENIX_CACHE_STATUS",
        version: CACHE_VERSION,
        entries: keys.length,
      });
    }),
  );
});
