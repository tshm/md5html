
self.importScripts('crypto-js.js')

self.addEventListener('message', function(e) {
  console.info(e)
  var hash = self.CryptoJS[e.data.algoname](arrayBufferToWordArray(e.data.data))
  self.postMessage({
    name: e.data.name,
    hash: hash.toString(self.CryptoJS.hex)
  })
}, false)

function arrayBufferToWordArray(ab) {
  var i8a = new Uint8Array(ab);
  var a = [];
  for (var i = 0; i < i8a.length; i += 4) {
    a.push(i8a[i] << 24 | i8a[i + 1] << 16 | i8a[i + 2] << 8 | i8a[i + 3]);
  }
  return CryptoJS.lib.WordArray.create(a, i8a.length);
}
