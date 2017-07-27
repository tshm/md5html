/* global Elm DEBUG */
var app = Elm.Md5html.fullscreen()
var worker = new Worker('worker.js')

worker.onmessage = function (obj) {
  app.ports.updatefile.send(obj.data)
}

worker.onerror = function () {
  console.error('reading file failure', e)
  app.ports.updatefile.send({ name: file.name, hash: 'failed to load' })
}

app.ports.clearFiles.subscribe(function () {
  var elem = document.getElementById('fileopener');
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

