!function(n,e){"use strict";var t=n.console||{log:function(){}},i=n.jQuery,r=n.angular,o=n.CybozuLabs,l=r.module("md5htmlApp",[]);l.config(["$compileProvider",function(n){n.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|blob):/)}]),l.controller("MainCtrl",["$scope","$window",function(n,e){n.supported=!!(e.File&&e.FileReader&&e.FileList)}]),l.factory("md5",["$q","$rootScope",function(e,i){var r=o.MD5,l={};return l.read=function(o){t.log("read callded: ",o);var l=e.defer(),c=new n.FileReader;return c.onload=function(n){l.resolve(r.calc(n.target.result)),i.$apply()},c.onerror=function(){t.log("onerror callded"),l.reject(this),i.$apply()},c.readAsBinaryString(o),l.promise},l}]),l.controller("md5",["$scope","$window","md5",function(i,r,o){i.files=[],i.$watch("filelist",function(n){if(n){for(var r=function(n){return function(e){n.md5=e,t.log("then called: ",e),i.makeTxt()}},l=n.length-1;l>=0;l--){var c=n[l];o.read(c).then(r(c)),c.md5="Calculating...",i.files.push(c)}i.filelist=e}}),i.clear=function(){i.files=[]};var l=r.URL||r.webkitURL;i.makeTxt=function(){var e=i.files.map(function(n){return n.name+", "+n.md5}).join("\n");i.md5href=l.createObjectURL(new n.Blob([e],{type:"text/plain"})),t.log(i.md5href)}}]),l.directive("selectAll",function(){return function(n,e){e.bind("click",function(){e.select()})}}),l.directive("dropArea",function(){return function(n,e,t){var r=function(n){n.stopPropagation(),n.preventDefault()};e.bind("dragover",r),e.bind("drop",function(e){r(e),n[t.dropArea]=e.dataTransfer.files,n.$apply()}),e.bind("click",function(){i("input").click()})}}),l.directive("filelistBind",function(){return function(n,e,t){e.bind("change",function(e){n.$apply(function(){n[t.name]=e.target.files})})}})}(window);