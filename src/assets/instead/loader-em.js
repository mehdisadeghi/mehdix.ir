var memFileSize = 1111191;

var appElement = document.getElementById('emscripten-app');
var statusElement = document.getElementById('emscripten-status');
var preloaderElement = document.getElementById('preloader');

var barPreloader = new ldBar("#emPreloader");
var barProgress = new ldBar("#emProgress", {"stroke-width": 5, "stroke": '#666666'});

var Module = {
  preRun: [],
  postRun: [],
  dataFileDownloads: {
  },
  print: (function() {
    return function(text) {
      if (arguments.length > 1) text = Array.prototype.slice.call(arguments).join(' ');
      console.log(text);
    };
  })(),
  printErr: function(text) {
    if (arguments.length > 1) text = Array.prototype.slice.call(arguments).join(' ');
    if (0) { // XXX disabled for safety typeof dump == 'function') {
      dump(text + '\n'); // fast, straight to the real console
    } else {
      console.error(text);
    }
  },
  canvas: (function() {
    var canvas = document.getElementById('canvas');

    // As a default initial behavior, pop up an alert when webgl context is lost. To make your
    // application robust, you may want to override this behavior before shipping!
    // See http://www.khronos.org/registry/webgl/specs/latest/1.0/#5.15.2
    canvas.addEventListener("webglcontextlost", function(e) { alert('WebGL context lost. You will need to reload the page.'); e.preventDefault(); }, false);

    return canvas;
  })(),
  setStatus: function(text) {
    if (text === 'Running') {
      preloaderElement.style.display = 'none';
      appElement.style.display = 'block';
    } else if (text.indexOf('Launching game') === 0) {
      barPreloader.set(100);
    } else if (this.dataFileDownloads.hasOwnProperty('game') && text.indexOf('Loading game') === 0) {
      var stInfo = this.dataFileDownloads['game'];
      barPreloader.set(66 + stInfo.loaded / stInfo.total * 34);
      barProgress.set(stInfo.loaded / stInfo.total * 100);
    } else if (this.dataFileDownloads.hasOwnProperty('instead-em.data')) {
      var stInfo = this.dataFileDownloads['instead-em.data'];
      barPreloader.set(33 + stInfo.loaded / stInfo.total * 33);
      barProgress.set(stInfo.loaded / stInfo.total * 100);
    }
    statusElement.innerHTML = text;
  }
};

Module.setStatus('Downloading...');
window.onerror = function(event) {
  // TODO: do not warn on ok events like simulating an infinite loop or exitStatus
  Module.setStatus('Exception thrown, see JavaScript console');
  // spinnerElement.style.display = 'none';
  Module.setStatus = function(text) {
    if (text) Module.printErr('[post-exception status] ' + text);
  };
};

// helper functions
function requestFullscreen () {
  Module.requestFullscreen(
    document.getElementById('pointerLock').checked, 
    document.getElementById('resize').checked
  );
}

// Memory loader
(function() {
  var memoryInitializer = 'instead-em.html.mem';
  if (typeof Module['locateFile'] === 'function') {
    memoryInitializer = Module['locateFile'](memoryInitializer);
  } else if (Module['memoryInitializerPrefixURL']) {
    memoryInitializer = Module['memoryInitializerPrefixURL'] + memoryInitializer;
  }
  var meminitXHR = Module['memoryInitializerRequest'] = new XMLHttpRequest();
  meminitXHR.open('GET', memoryInitializer, true);
  meminitXHR.responseType = 'arraybuffer';
  meminitXHR.send(null);
  statusElement.innerHTML = 'Downloading memory snapshot';
  meminitXHR.onprogress = function(ev) {
    barPreloader.set(ev.loaded/memFileSize * 33);
    barProgress.set(ev.loaded/memFileSize * 100);
  }
})();

// Main script loader
var emScript = document.createElement('script');
emScript.src = "instead-em.js";
document.body.appendChild(emScript);
