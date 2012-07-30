express = require('express')
routes = require('./routes')
fs=require('fs')
path=require('path')
app = module.exports = express.createServer();


app.configure ()->
	app.set 'port', process.env.PORT || 3000
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	app.use express.favicon()
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use express.compress
		filter:(req,res)->
			ctype=res.getHeader('Content-Type')
			ctype? and ctype.match(/json|text|javascript/)!=null
	app.use express.static(__dirname + '/public')
	app.use app.router

app.configure 'development', ()->
	app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));

app.configure 'production', ()->
	app.use(express.errorHandler());

# Routes
views=require('./views')
views(app,routes);





app.listen 3000, ()->
	console.log "Express server listening on port %d in %s mode", 3000, app.settings.env