// handle missing window.console.log cases.
window.console = window.console || {log: function(){}};

var app = angular.module('app', []);

app.controller('MainCtrl', function( $scope ) {
  $scope.supported = !!(window.File && window.FileReader && window.FileList);
});

app.factory('md5', function( $q, $rootScope ) {
  var engine = CybozuLabs.MD5;
  var md5 = {};
  md5.read = function( file ) {
    console.log("read callded: ", file);
    var deffered = $q.defer();
    var reader = new FileReader();
    reader.onload = function( event ) {
      deffered.resolve( engine.calc( event.target.result ));
      $rootScope.$apply();
    };
    reader.onerror = function( event ) {
      console.log("onerror callded");
      deffered.reject( this );
      $rootScope.$apply();
    };
    reader.readAsBinaryString( file );
    return deffered.promise;
  };
  return md5;
});

app.controller('md5', function($scope, md5) {
  $scope.files = [];

  $scope.$watch( 'filelist', function( filelist ) {
		//console.log( filelist );
    if ( !filelist ) return;
    $scope.files = [];
    var then = function( file ) {
      return function( result ) {
        file.md5 = result;
        console.log("then called: ", result);
      };
    };
    console.log( filelist );
    for ( var i = filelist.length - 1; i >= 0; i-- ) {
      var file = filelist[i];
      md5.read( file ).then( then( file ) );
      file.md5 = 'Calculating...';
      $scope.files.push( file );
    }
  });
  
  $scope.clear = function() {
    $scope.files = [];
  };

});

app.directive('selectAll', function() {
  return function( scope, elm, attrs ) {
    elm.bind('hover', function() {
      elm.select();
		});
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
