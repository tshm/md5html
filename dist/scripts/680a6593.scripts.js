!function(a,b){"use strict";var c=a.console||{log:function(){}},d=a.jQuery,e=a.angular,f=a.CybozuLabs,g=e.module("md5htmlApp",[]);g.controller("MainCtrl",["$scope","$window",function(a,b){a.supported=!!(b.File&&b.FileReader&&b.FileList)}]),g.factory("md5",["$q","$rootScope",function(a,b){var d=f.MD5,e={};return e.read=function(e){c.log("read callded: ",e);var f=a.defer(),g=new FileReader;return g.onload=function(a){f.resolve(d.calc(a.target.result)),b.$apply()},g.onerror=function(){c.log("onerror callded"),f.reject(this),b.$apply()},g.readAsBinaryString(e),f.promise},e}]),g.controller("md5",["$scope","$window","md5",function(a,d,e){a.files=[],a.$watch("filelist",function(d){if(d){for(var f=function(b){return function(d){b.md5=d,c.log("then called: ",d),a.makeTxt()}},g=d.length-1;g>=0;g--){var h=d[g];e.read(h).then(f(h)),h.md5="Calculating...",a.files.push(h)}a.filelist=b}}),a.clear=function(){a.files=[]};var f=d.URL||d.webkitURL;a.makeTxt=function(){var b=a.files.map(function(a){return a.name+", "+a.md5}).join("\n");a.md5href=f.createObjectURL(new Blob([b],{type:"text/plain"}))}}]),g.directive("selectAll",function(){return function(a,b){b.bind("click",function(){b.select()})}}),g.directive("dropArea",function(){return function(a,b,c){var e=function(a){a.stopPropagation(),a.preventDefault()};b.bind("dragover",e),b.bind("drop",function(b){e(b),a[c.dropArea]=b.originalEvent.dataTransfer.files,a.$apply()}),b.bind("click",function(){d("input").click()})}}),g.directive("filelistBind",function(){return function(a,b,c){b.bind("change",function(b){a.$apply(function(){a[c.name]=b.target.files})})}})}(window);