express = require('express')
routes = require('./routes')
fs=require('fs')
path=require('path')
cp=require('child_process')


exec=(cmd,cb)->
  c=cp.exec cmd,{stdio: 'inherit'}
  c.stdout.on 'data',(data)->
    if data? and data.trim().length
      console.log data
  c.stderr.on 'data',(data)->
    if data? and data.trim().length
      console.error data
  c.on 'exit',if cb? then cb else ()->


switch process.argv[2]
  when 'dev'
    viewsDir=path.join __dirname,'views/'
    fs.watch viewsDir,(event, f)->
      if !f? or !f.match '.jade$'
        return
      target=viewsDir+f.substring(0,f.length-4)+'htm'
      if fs.existsSync target
        fs.unlinkSync target
      await exec "cp #{__dirname}/page.debug.htm #{target}",defer err
      console.log "generated #{target}"
    exec "cake watch"
    return
  when 'libs'
    require('./libs').get()
    return
  when 'deploy'
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
