self.importScripts('crypto-js.js')

self.addEventListener('message', function(e) {
  var hash = self.CryptoJS[e.data.algoname](arrayBufferToWordArray(e.data.buffer))
  self.postMessage({
    name: e.data.name,
    hash: hash.toString()
  })
}, false)

function arrayBufferToWordArray(arrayBuf) {
  var intArr = new Uint8Array(arrayBuf);
  var wordArr = [];
  for (var i = 0; i < intArr.length; i += 4) {
    var v = intArr[i] << 24 | intArr[i + 1] << 16 | intArr[i + 2] << 8 | intArr[i + 3]
    wordArr.push(v);
  }
  return CryptoJS.lib.WordArray.create(wordArr, intArr.length);
}
