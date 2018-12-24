/* global Elm Worker DEBUG */
import { Elm } from './Main.elm';
const app = Elm.Md5html.init({
  node: document.getElementById('elm')
});
const worker = new Worker('./worker.js');
worker.postMessage(false);  // load script

worker.onmessage = function (obj) {
  const data = obj.data;
  app.ports.updatefile.send(data);
}

app.ports.clearFiles.subscribe(function () {
  const elem = document.getElementById('fileopener');
  elem.value = null;
});

app.ports.openFiles.subscribe(function (arg) {
  const arrFiles = [].slice.call(arg.files);
  if (DEBUG) console.log('algoname', arg.algoname);
  if (DEBUG) console.log('file(s) added:', arrFiles);

  arrFiles.forEach(function (file) {
    app.ports.addfile.send(file.name);
    worker.postMessage({
      algoname: arg.algoname,
      file: file
    });
  });
});

console.log('loaded...');
