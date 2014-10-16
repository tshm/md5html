(function( window, undefined ) {
  'use strict';
  // handle missing window.console.log cases.
  var console = window.console || {log: function(){}},
    angular = window.angular,
    CybozuLabs = window.CybozuLabs;

  var app = angular.module('md5htmlApp', []);

  app.config(function( $compileProvider ) {   
    $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|blob):/);
  });

  app.controller('MainCtrl', function( $scope, $window ) {
    $scope.supported = !!($window.File && $window.FileReader && $window.FileList);
  });

  app.factory('md5', function( $q, $rootScope ) {
    var engine = CybozuLabs.MD5;
    var md5 = {};
    md5.read = function( file ) {
      console.log('read callded: ', file);
      var deffered = $q.defer();
      var reader = new window.FileReader();
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
      filelist.forEach(function( file ) {
        md5.read( file ).then( then( file ) );
        file.md5 = 'Calculating...';
        $scope.files.push( file );
      });
      $scope.filelist = undefined;
    });

    $scope.clear = function() {
      $scope.files = [];
    };

    var URL = $window.URL || $window.webkitURL;
    $scope.makeTxt = function() {
      var txt = $scope.files.map(function(f) { return f.name + ', ' + f.md5; }).join('\n');
      $scope.md5href = URL.createObjectURL( new window.Blob([ txt ], {type: 'text/plain'}) );
      console.log( $scope.md5href );
    };
  });

  app.directive('selectAll', function() {
    return function( scope, elm ) {
      elm.bind('click', function() {
        elm.select();
      });
    };
  });

  app.directive('dropArea', function( $window ) {
    return function( scope, elm, attrs ) {
      var takeOverEvent = function( evt ) {
        evt.stopPropagation();
        evt.preventDefault();
      };
      elm.bind('dragover', takeOverEvent );
      elm.bind('drop', function( evt ) {
        takeOverEvent( evt );
        scope[ attrs.dropArea ] = [].slice.cll( evt.dataTransfer.files );
        //scope[ attrs.dropArea ] = evt.originalEvent.dataTransfer.files;
        scope.$apply();
      });
      elm.bind('click', function() {
        $window.document.getElementsByTagName('input')[0].click();
      });
    };
  });

  app.directive('filelistBind', function() {
    return function( scope, elm, attrs ) {
      elm.bind('change', function( evt ) {
        scope.$apply(function() {
          var files = [].slice.call( evt.target.files );
          scope[ attrs.name ] = files;
          //console.log( scope[ attrs.name ] );
        });
      });
    };
  });
})( window );
