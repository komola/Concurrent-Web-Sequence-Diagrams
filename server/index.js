
// This is a simple example sharejs server which hosts the sharejs
// examples in examples/.
//
// It demonstrates a few techniques to get different application behaviour.

require('coffee-script');
var connect = require('connect'),
		sharejs = require('share'),
		hat = require('hat').rack(32, 36);

var argv = require('optimist').
usage("Usage: $0 [-p portnum]").
default('p', 8000).
alias('p', 'port').
argv;

var server = connect(
		connect.favicon(),
		connect.static(__dirname + '/../client/assets/'),
		connect.router(function (app) {
			//var renderer = require('/assets/_static');
			//app.get('/static/:docName', function(req, res, next) {
				//var docName;
				//docName = req.params.docName;
				//renderer(docName, server.model, res, next);
			//});
			app.get('/new', function(req, res, next) {
				res.writeHead(302, {location: '/?' + connect.utils.uid(8)});
				res.end();
			})

			app.get('/?', function(req, res, next) {
				res.writeHead(302, {location: '/index.html'});
				res.end();
			});
		})
);

var options = {
	db: {type: 'none'},
	auth: function(client, action) {
		// This auth handler rejects any ops bound for docs starting with 'readonly'.
		if (action.name === 'submit op' && action.docName.match(/^readonly/)) {
			action.reject();
		} else {
			action.accept();
		}
	}
};

// Lets try and enable redis persistance if redis is installed...
try {
	require('redis');
	options.db = {type: 'redis'};
} catch (e) {}

console.log("ShareJS example server v" + sharejs.version);
console.log("Options: ", options);

var port = argv.p;

// Attach the sharejs REST and Socket.io interfaces to the server
sharejs.server.attach(server, options);

server.listen(port);
console.log("Demos running at http://localhost:" + port);

process.title = 'sharejs'
process.on('uncaughtException', function (err) {
	console.error('An error has occurred. Please file a ticket here: https://github.com/josephg/ShareJS/issues');
	console.error('Version ' + sharejs.version + ': ' + err.stack);
});
