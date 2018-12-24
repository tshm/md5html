/* global self */
const CryptoJS = require('crypto-js');

self.onmessage = function (e) {
  if (!e.data) return;
  const reader = new self.FileReader();
  const file = e.data.file;

  reader.onload = function (ev) {
    const array = arrayBufferToWordArray(ev.target.result);
    const hash = CryptoJS[e.data.algoname](array);
    self.postMessage({
      name: file.name,
      hash: hash.toString()
    });
  }

  reader.onerror = function (e) {
    self.postMessage({
      file: file.name,
      hash: 'file read error...'
    });
  }

  reader.readAsArrayBuffer(file);
}

function arrayBufferToWordArray (arrayBuf) {
  const intArr = new Uint8Array(arrayBuf);
  const wordArr = [];
  for (let i = 0; i < intArr.length; i += 4) {
    const v = intArr[i] << 24 | intArr[i + 1] << 16 | intArr[i + 2] << 8 | intArr[i + 3];
    wordArr.push(v);
  }
  return CryptoJS.lib.WordArray.create(wordArr, intArr.length);
}
