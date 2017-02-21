const PRECACHE = 'v1'
const RUNTIME = 'runtime'

const PRECACHE_URLS = [
  'index.html',
  './', // Alias for index.html
  'src/main.css',
  'src/bower_components/jshashes/hashes.min.js',
  'bundle.js',
]

self.addEventListener('install', ev => {
  ev.waitUntil(
    caches.open(PRECACHE)
      .then(cache => cache.addAll(PRECACHE_URLS))
      .then(self.skipWaiting())
  )
})

self.addEventListener('fetch', ev => {
  ev.respondWith(
    caches.match(ev.request).then( response =>
      response || fetch(ev.request)
    )
  )
})

