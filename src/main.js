/* global Worker */
import { Elm } from "./Main.elm";
const app = Elm.Main.init({
  node: document.getElementById("elm"),
});
const worker = new Worker(new URL("./worker.js", import.meta.url), {
  type: "module",
});
worker.postMessage(false); // load script
const DEBUG = process.env.NODE_ENV === "development";

worker.onmessage = function (obj) {
  const data = obj.data;
  app.ports.updatefile.send(data);
};

app.ports.clearFiles.subscribe(function () {
  const elem = document.getElementById("fileopener");
  elem.value = null;
});

app.ports.openFiles.subscribe(function (arg) {
  console.time("openFiles() called");
  const arrFiles = [].slice.call(arg.files);
  if (DEBUG) console.log("algoname", arg.algoname);
  if (DEBUG) console.log("file(s) added:", arrFiles);

  arrFiles.forEach(function (file) {
    console.log("sending", file.name);
    app.ports.addfile.send(file.name);
    worker.postMessage({
      algoname: arg.algoname,
      file: file,
    });
  });
  console.timeEnd("openFiles() called");
});

console.log("loaded...");
