Offline MD5 Calculator.
=======================

[![Build Status](https://travis-ci.org/tshm/md5html.svg?branch=master)](https://travis-ci.org/tshm/md5html)
[![Stories in Ready](https://badge.waffle.io/tshm/md5html.png?label=ready&title=Ready)](https://waffle.io/tshm/md5html)

The server-less web application for calculating MD5 digest
for the given files.
It uses:

* [elm](http://elm-lang.org/) 
* html5 (FILE API / webworker / service worker)
* [CryptoJS](https://code.google.com/archive/p/crypto-js/)
  to accomplish the hashing job.
* [workbox](https://workboxjs.org/)
  to make the site PWA (service worker).

[note]
Due to the FILE API limitation, it may not work for large files.

