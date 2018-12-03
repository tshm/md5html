/* global self */
self.importScripts('crypto-js.js')

self.onmessage = function (e) {
  if (!e.data) return
  var reader = new self.FileReader()
  var file = e.data.file

  reader.onload = function (ev) {
    var array = arrayBufferToWordArray(ev.target.result)
    var hash = self.CryptoJS[e.data.algoname](array)
    self.postMessage({
      name: file.name,
      hash: hash.toString()
    })
  }

  reader.onerror = function (e) {
    self.postMessage({
      file: file.name,
      hash: 'file read error...'
    })
  }

  reader.readAsArrayBuffer(file)
}

function arrayBufferToWordArray (arrayBuf) {
  var intArr = new Uint8Array(arrayBuf)
  var wordArr = []
  for (var i = 0; i < intArr.length; i += 4) {
    var v = intArr[i] << 24 | intArr[i + 1] << 16 | intArr[i + 2] << 8 | intArr[i + 3]
    wordArr.push(v)
  }
  return self.CryptoJS.lib.WordArray.create(wordArr, intArr.length)
}
