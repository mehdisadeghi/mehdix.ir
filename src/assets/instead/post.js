var Module;
FS.mkdir('/appdata');
FS.mount(IDBFS,{},'/appdata');

Module['postRun'].push(function() {
	var argv = []
	var req
	var url

	var metatags = document.getElementsByTagName('meta');

	for (var mt = 0; mt < metatags.length; mt++) { 
		if (metatags[mt].getAttribute("name") === "gamefile") {
			url = metatags[mt].getAttribute("content");
		}
	}

	if (!url && typeof window === "object") {
		argv = window.location.search.substr(1).trim().split('&');
		if (!argv[0])
			argv = [];
		url = argv[0];
	}

	if (!url)
		url='data.zip?'+(Math.random()*10000000);

	req = new XMLHttpRequest();
	req.open("GET", url, true);
	req.responseType = "arraybuffer";
	console.log("Get: ", url);

	req.onprogress = function(ev) {
		Module.dataFileDownloads['game'] = {
			loaded: ev.loaded,
			total: ev.total
		};
		Module["setStatus"]("Downloading game (" + ev.loaded + "/" + ev.total + ")")
	};

	req.onload = function() {
		var basename = function(path) {
			parts = path.split( '/' );
			return parts[parts.length - 1];
		}
		var data = req.response;
		console.log("Data loaded...");
		Module["setStatus"]("Launching game, please wait...");
		FS.syncfs(true, function (error) {
			if (error) {
				console.log("Error while syncing: ", error);
			}
			url = basename(url);
			console.log("Writing: ", url);
			FS.writeFile(url, new Int8Array(data), { encoding: 'binary' }, "w");
			Module["setStatus"]("Running");
			console.log("Running...");
			var args = [];
			[ "instead-em", url, "-standalone", "-window", "-resizable", "-mode" ].forEach(function(item) {
				args.push(allocate(intArrayFromString(item), 'i8', ALLOC_NORMAL));
				args.push(0); args.push(0); args.push(0);
			})
			args = allocate(args, 'i32', ALLOC_NORMAL);
			setTimeout(function() {
				Module.setStatus('');
				document.getElementById('status').style.display = 'none';
			}, 3);
			window.onclick = function(){ window.focus() };
			Module.ccall('instead_main', 'number', ["number", "number"], [6, args ]);
		});
	}
	req.send(null);
});
