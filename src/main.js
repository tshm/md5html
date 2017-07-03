/* global Elm DEBUG Hashes */
var app = Elm.Md5html.fullscreen()

app.ports.openFiles.subscribe(function (arg) {
  if (DEBUG) console.log('algoname', arg.algoname)
  var engine = new Hashes[ arg.algoname ]()
  var arrFiles = [].slice.call(arg.files)
  if (DEBUG) console.log('file(s) added:', arrFiles)

  arrFiles.forEach(function (file) {
    app.ports.addfile.send(file.name)
    var reader = new window.FileReader()

    reader.onload = function (ev) {
      var hash = engine.hex(ev.target.result)
      app.ports.updatefile.send({ name: file.name, hash: hash })
    }

    reader.onerror = function (e) {
      console.error('reading file failure', e)
      app.ports.updatefile.send({name: file.name, hash: 'failed to load'})
    }

    reader.readAsBinaryString(file)
  })
})

