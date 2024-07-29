const CACHE_NAME = "shift-view-cache-v1";
const urlsToCache = [
  "/",
  "/index.html",
  "/main.dart.js",
  "/styles.css",
  "/manifest.json",
  "/assets/fonts/MaterialIcons-Regular.otf",
  // Add other assets your app needs to work offline
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      if (response) {
        return response;
      }
      return fetch(event.request);
    })
  );
});