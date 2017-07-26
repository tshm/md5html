/* global Elm DEBUG */
var app = Elm.Md5html.fullscreen()
var worker = new Worker('worker.js')

worker.addEventListener('message', function(obj) {
  app.ports.updatefile.send(obj.data)
}, false)

app.ports.openFiles.subscribe(function (arg) {
  if (DEBUG) console.log('algoname', arg.algoname)
  var arrFiles = [].slice.call(arg.files)
  if (DEBUG) console.log('file(s) added:', arrFiles)

  arrFiles.forEach(function (file) {
    app.ports.addfile.send(file.name)
    var reader = new window.FileReader()

    reader.onload = function (ev) {
      worker.postMessage({
        algoname: arg.algoname,
        buffer: ev.target.result,
        name: file.name
      })
    }

    reader.onerror = function (e) {
      console.error('reading file failure', e)
      app.ports.updatefile.send({name: file.name, hash: 'failed to load'})
    }

    reader.readAsArrayBuffer(file)
  })
})

