importScripts('workbox-sw.prod.v1.0.1.js');

/**
 * DO NOT EDIT THE FILE MANIFEST ENTRY
 *
 * The method precache() does the following:
 * 1. Cache URLs in the manifest to a local cache.
 * 2. When a network request is made for any of these URLs the response
 *    will ALWAYS comes from the cache, NEVER the network.
 * 3. When the service worker changes ONLY assets with a revision change are
 *    updated, old cache entries are left as is.
 *
 * By changing the file manifest manually, your users may end up not receiving
 * new versions of files because the revision hasn't changed.
 *
 * Please use workbox-build or some other tool / approach to generate the file
 * manifest which accounts for changes to local files and update the revision
 * accordingly.
 */
const fileManifest = [
  {
    "url": "/index.html",
    "revision": "eed252922ee26a19d9672cacb1ee54b3"
  },
  {
    "url": "/src/main.css",
    "revision": "d669e09490ad0a547d9d022f97c37fef"
  },
  {
    "url": "/bundle.js",
    "revision": "f0111897d7f295de6fc9e76431b9c7c9"
  },
  {
    "url": "/src/bower_components\\jshashes\\hashes.min.js",
    "revision": "ae639f81fe09340949e3637d6733204c"
  },
  {
    "url": "/manifest.json",
    "revision": "e1c829b6f4142dcedc369f4201d01af3"
  }
];

const workboxSW = new self.WorkboxSW();
workboxSW.precache(fileManifest);
