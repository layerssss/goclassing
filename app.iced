express = require('express')
routes = require('./routes')
fs=require('fs')
path=require('path')
cp=require('child_process')
os=require 'os'
exec=(cmd,cb)->
  if os.type().toLowerCase().indexOf('windows')!=-1
    cmd=cmd.replace /\//g,'\\'
  console.log cmd
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
      await fs.exists target,defer exists
      if exists
        await fs.unlink target,defer err
      await exec "cp #{__dirname}/page.debug.htm #{target}",defer err
      console.log "generated #{target}"
    exec "cake watch"
    return
  when 'folk'
    dest=process.argv[3]
    await exec "cp #{__dirname}/app.iced #{dest}/",defer err
    await exec "cp #{__dirname}/routes.iced #{dest}/",defer err

    await exec "cp #{__dirname}/Cakefile #{dest}/",defer err
    await exec "cp #{__dirname}/page.debug.htm #{dest}/",defer err
    await exec "cp #{__dirname}/package.json #{dest}/",defer err


    await exec "mkdir #{dest}/views"
    await exec "mkdir #{dest}/libs"
    await exec "cp #{__dirname}/views/debug.page.iced #{dest}/views/",defer err
    return
  else
app = module.exports = express.createServer();


app.configure ()->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

app.configure 'development', ()->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));

app.configure 'production', ()->
  app.use(express.errorHandler());

# Routes

require('./views')(app,routes);

app.listen 3000, ()->
  console.log "Express server listening on port %d in %s mode", 3000, app.settings.env