express = require('express')
routes = require('./routes')
fs=require('fs.extra')
path=require('path')

if process.argv[2]=='dev'
  viewsDir=path.join __dirname,'views/'
  fs.readdirSync(viewsDir).forEach (f)->
    if !f.match '.jade$'
      false
    target=viewsDir+f.substring(0,f.length-4)+'htm'
    if fs.existsSync target
      fs.unlinkSync target
    fs.copy path.join(__dirname,'page.debug.htm'),target
  require('./libs').get()
  return
if process.argv[2]=='deploy'
  require('./libs').deploy()
  return
app = module.exports = express.createServer();


app.configure ()->
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));

app.configure 'development', ()->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));

app.configure 'production', ()->
  app.use(express.errorHandler());

# Routes

require('./views')(app,routes);

app.listen 3000, ()->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
