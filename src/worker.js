self.importScripts('crypto-js.js')

self.onmessage = function (e) {
  var reader = new self.FileReader()
  var file = e.data.file;

  reader.onload = function (ev) {
    var hash = self.CryptoJS[e.data.algoname](arrayBufferToWordArray(ev.target.result))
    self.postMessage({
      name: file.name,
      hash: hash.toString()
    })
  }

  reader.onerror = function (e) {
    self.postMessage({ error: `cannot read file #{e}`})
  }

  reader.readAsArrayBuffer(file)

}

function arrayBufferToWordArray(arrayBuf) {
  var intArr = new Uint8Array(arrayBuf);
  var wordArr = [];
  for (var i = 0; i < intArr.length; i += 4) {
    var v = intArr[i] << 24 | intArr[i + 1] << 16 | intArr[i + 2] << 8 | intArr[i + 3]
    wordArr.push(v);
  }
  return CryptoJS.lib.WordArray.create(wordArr, intArr.length);
}
