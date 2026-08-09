const CACHE_VERSION = "phoenix-offline-v270";
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
