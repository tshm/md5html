/* global Elm Worker DEBUG */
var app = Elm.Md5html.init({
  node: document.getElementById('elm')
})
var worker = new Worker('worker.js')
worker.postMessage(false)  // load script

worker.onmessage = function (obj) {
  var data = obj.data
  app.ports.updatefile.send(data)
}

app.ports.clearFiles.subscribe(function () {
  var elem = document.getElementById('fileopener')
  elem.value = null
})

app.ports.openFiles.subscribe(function (arg) {
  var arrFiles = [].slice.call(arg.files)
  if (DEBUG) console.log('algoname', arg.algoname)
  if (DEBUG) console.log('file(s) added:', arrFiles)

  arrFiles.forEach(function (file) {
    app.ports.addfile.send(file.name)
    worker.postMessage({
      algoname: arg.algoname,
      file: file
    })
  })
})
