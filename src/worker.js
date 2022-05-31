/* eslint-disable no-bitwise */
const CryptoJS = require('crypto-js');

function arrayBufferToWordArray(arrayBuf) {
  const intArr = new Uint8Array(arrayBuf);
  const wordArr = [];
  for (let i = 0; i < intArr.length; i += 4) {
    const v =
      (intArr[i] << 24) |
      (intArr[i + 1] << 16) |
      (intArr[i + 2] << 8) |
      intArr[i + 3];
    wordArr.push(v);
  }
  return CryptoJS.lib.WordArray.create(wordArr, intArr.length);
}

onmessage = function onmessage(e) {
  if (!e.data) return;
  const reader = new FileReader();
  const { file } = e.data;

  reader.onload = function onload(ev) {
    const array = arrayBufferToWordArray(ev.target.result);
    const hash = CryptoJS[e.data.algoname](array);
    postMessage({
      name: file.name,
      hash: hash.toString(),
    });
  };

  reader.onerror = function onerror() {
    postMessage({
      file: file.name,
      hash: 'file read error...',
    });
  };

  postMessage({
    name: file.name,
    hash: 'start processing...',
  });
  reader.readAsArrayBuffer(file);
};
