var engine = CybozuLabs.MD5;
var app = Elm.Md5html.fullscreen();

app.ports.openFileDialog.subscribe(function(v) {
  if (!v) return;
  document.querySelector('#fileopener').click();
});

app.ports.updateFiles.subscribe(function( files ) {
  var arrFiles = [].slice.call( files );
  // console.log('file(s) added: ', arrFiles );
  arrFiles.forEach(function( file ) {
    app.ports.file.send({ name: file.name, md5: '...'});
    var reader = new window.FileReader();
    reader.onload = function( ev ) {
      var md5 = engine.calc( ev.target.result );
      app.ports.file.send({ name: file.name, md5: md5 });
    };
    reader.onerror = function() {
      console.error('reading file failure');
    };
    reader.readAsBinaryString( file );
  });
});

