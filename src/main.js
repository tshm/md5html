var app = Elm.Md5html.fullscreen();

app.ports.openFileDialog.subscribe(function( v ) {
  if ( !v ) return;
  document.querySelector('#fileopener').click();
});

app.ports.openFiles.subscribe(function( arg ) {
  if ( DEBUG ) {
    console.log('algoname', arg.algoname );
  }
  var engine = new Hashes[ arg.algoname ];
  var arrFiles = [].slice.call( arg.files );
  if ( DEBUG ) {
    console.log('file(s) added:', arrFiles );
  }
  arrFiles.forEach(function( file ) {
    app.ports.file.send({ name: file.name, hash: '...'});
    var reader = new window.FileReader();
    reader.onload = function( ev ) {
      var hash = engine.hex( ev.target.result );
      app.ports.file.send({ name: file.name, hash: hash });
    };
    reader.onerror = function( e ) {
      console.error('reading file failure', e );
      app.ports.file.send({ name: file.name, hash: 'failed to load'});
    };
    reader.readAsBinaryString( file );
  });
});

