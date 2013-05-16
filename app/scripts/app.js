(function( window, undefined ) {
  'use strict';
  // handle missing window.console.log cases.
  var console = window.console || {log: function(){}},
    $ = window.jQuery,
    angular = window.angular,
    CybozuLabs = window.CybozuLabs;

  var app = angular.module('md5htmlApp', []);

  app.controller('MainCtrl', function( $scope, $window ) {
    $scope.supported = !!($window.File && $window.FileReader && $window.FileList);
  });

  app.factory('md5', function( $q, $rootScope ) {
    var engine = CybozuLabs.MD5;
    var md5 = {};
    md5.read = function( file ) {
      console.log('read callded: ', file);
      var deffered = $q.defer();
      var reader = new FileReader();
      reader.onload = function( event ) {
        deffered.resolve( engine.calc( event.target.result ));
        $rootScope.$apply();
      };
      reader.onerror = function() {
        console.log('onerror callded');
        deffered.reject( this );
        $rootScope.$apply();
      };
      reader.readAsBinaryString( file );
      return deffered.promise;
    };
    return md5;
  });

  app.controller('md5', function( $scope, $window, md5 ) {
    $scope.files = [];

    $scope.$watch('filelist', function( filelist ) {
      if ( !filelist ) { return; }
      var then = function( file ) {
        return function( result ) {
          file.md5 = result;
          console.log('then called: ', result);
          $scope.makeTxt();
        };
      };
      for ( var i = filelist.length - 1; i >= 0; i-- ) {
        var file = filelist[i];
        md5.read( file ).then( then( file ) );
        file.md5 = 'Calculating...';
        $scope.files.push( file );
      }
      $scope.filelist = undefined;
    });

    $scope.clear = function() {
      $scope.files = [];
    };

    var URL = $window.URL || $window.webkitURL;
    $scope.makeTxt = function() {
      var txt = $scope.files.map(function(f) { return f.name + ', ' + f.md5; }).join('\n');
      $scope.md5href = URL.createObjectURL( new Blob([ txt ], {type: 'text/plain'}) );
    };
  });

  app.directive('selectAll', function() {
    return function( scope, elm ) {
      elm.bind('focus', function() {
        elm.select();
      });
    };
  });

  app.directive('dropArea', function() {
    return function( scope, elm, attrs ) {
      var takeOverEvent = function( event ) {
        event.stopPropagation();
        event.preventDefault();
      };
      elm.bind('dragover', takeOverEvent );
      elm.bind('drop', function( event ) {
        takeOverEvent( event );
        scope[ attrs.dropArea ] = event.originalEvent.dataTransfer.files;
        scope.$apply();
      });
      elm.bind('click', function() {
        $('input').click();
      });
    };
  });

  app.directive('filelistBind', function() {
    return function( scope, elm, attrs ) {
      elm.bind('change', function( evt ) {
        scope.$apply(function() {
          scope[ attrs.name ] = evt.target.files;
          //console.log( scope[ attrs.name ] );
        });
      });
    };
  });
})( window );
