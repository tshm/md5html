import { Elm } from './Main.elm';

const app = Elm.Main.init({
  node: document.getElementById('elm'),
});
const worker = new Worker(new URL('./worker.js', import.meta.url), {
  type: 'module',
});
worker.postMessage(false); // load script
const DEBUG = process.env.NODE_ENV === 'development';

worker.onmessage = function onmessage(obj) {
  const { data } = obj;
  app.ports.updatefile.send(data);
};

app.ports.clearFiles.subscribe(() => {
  const elem = document.getElementById('fileopener');
  elem.value = null;
});

app.ports.openFiles.subscribe((arg) => {
  console.time('openFiles() called');
  const arrFiles = [].slice.call(arg.files);
  if (DEBUG) console.log('algoname', arg.algoname);
  if (DEBUG) console.log('file(s) added:', arrFiles);

  arrFiles.forEach((file) => {
    console.log('sending', file.name);
    app.ports.addfile.send(file.name);
    worker.postMessage({
      algoname: arg.algoname,
      file,
    });
  });
  console.timeEnd('openFiles() called');
});

console.log('loaded...');
