var app = angular.module('app', []);

app.controller('MainCtrl', function($scope) {
  $scope.supported = !!(window.File && window.FileReader && window.FileList && window.Blob);
});

app.controller('md5', function($scope) {
  $scope.files = [];

  $scope.$watch( 'filelist', function( filelist ) {
    if ( !filelist ) return;
    $scope.files = [];
    for ( var i = 0, file; file = filelist[i]; i++ ) {
      file.md5 = '...';
      $scope.showmd5( file );
      $scope.files.push( file );
    }
  });
  
  $scope.showmd5 = function( file ) {
    var reader = new FileReader();
    reader.onloadend = function( event ) {
      if ( event.target.readyState == FileReader.DONE ) {
        $scope.$apply(function(){
          file.md5 = CybozuLabs.MD5.calc( event.target.result );
        });
      }
    };
    reader.readAsBinaryString( file );
  };
  
  $scope.clear = function() {
    $scope.files = [];
  };
});

app.directive('dropArea', function() {
  return function( scope, elm, attrs ) {
    elm.bind("dragover", function( event ) {
      event.stopPropagation();
      event.preventDefault();
    });
    elm.bind("drop", function( event ) {
      event.stopPropagation();
      event.preventDefault();
      scope.$apply(function( scope ) {
        scope[ attrs.dropArea ] = event.originalEvent.dataTransfer.files;
      });
    });
    elm.bind('click', function() {
      $('input').click();
    });
  };
});

app.directive("filelistBind", function() {
  return function( scope, elm, attrs ) {
    elm.bind("change", function( evt ) {
      //console.log( evt );
      scope.$apply(function( scope ) {
        scope[ attrs.name ] = evt.target.files;
      });
    });
  };
});
