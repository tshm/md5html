var engine = CybozuLabs.MD5;
var app = Elm.fullscreen(Elm.Md5html, {file: { name: '', md5: ''}});
var ff = document.querySelector('#ff');
ff.addEventListener('change', handleFiles, false );
function handleFiles() {
  addFiles( this.files );
}
function addFiles( files ) {
  var arrFiles = [].slice.call( files );
  console.log('file(s) added: ', arrFiles );
  arrFiles.forEach(function( file ) {
    app.ports.file.send({ name: file.name, md5: '...'});
    var reader = new window.FileReader();
    reader.onload = function( ev ) {
      var md5 = engine.calc( ev.target.result );
      app.ports.file.send({ name: file.name, md5: md5 });
    };
    reader.onerror = function() {
      console.log('onerror callded');
    };
    reader.readAsBinaryString( file );
  });
}
var dropbox = document.querySelector('#dropbox');
dropbox.addEventListener('click', function() {
  ff.click();
}, false);
dropbox.addEventListener('dragover', cancelEvent, false);
dropbox.addEventListener('drop', handleFileDrop, false);
function cancelEvent(ev) {
  ev.stopPropagation();
  ev.preventDefault();
}
function handleFileDrop(ev) {
  cancelEvent( ev );
  console.log('drop', ev );
  addFiles( ev.dataTransfer.files );
}
// Blob handling
function updateURL( files ) {
  if (files.some(function(f) { return f.md5 == '...'; })) { return; }
  console.log('md5 ports updated: ', files );
  var URL = window.URL || window.webkitURL;
  var txt = files.map(function(f) { return f.name + ', ' + f.md5; }).join('\n');
  var url = URL.createObjectURL( new window.Blob([ txt ], {type: 'text/plain'}) );
  document.querySelector('#download').setAttribute('href', url);
}
app.ports.md5.subscribe( updateURL );
