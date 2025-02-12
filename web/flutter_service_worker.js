// Flutter service worker
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open('flutter-app-cache').then((cache) => {
      return cache.addAll([
        '/',
        '/index.html',
        '/main.dart.js',
        '/flutter_bootstrap.js',
        'https://fonts.gstatic.com/s/roboto/v20/KFOmCnqEu92Fr1Me5WZLCzYlKw.ttf',
      ]);
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request).catch(() => {
        // Return cached version if network request fails
        return caches.match(event.request);
      });
    })
  );
});

// Handle errors
self.addEventListener('error', (event) => {
  console.error('Service worker error:', event.error);
}); 