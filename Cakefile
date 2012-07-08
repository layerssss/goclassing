fs = require 'fs'
coffee=require 'iced-coffee-script'
cp=require('child_process')
exec=(cmd,cb)->
	c=cp.exec cmd,{stdio: 'inherit'}
	c.stdout.on 'data',(data)->
		console.log data
	c.stderr.on 'data',(data)->
		console.error data
	c.on 'exit',if cb? then cb else ()->

task 'build', 'compile iced-coffee-scripts', (options) ->
	fs.readdirSync(__dirname).forEach (f)->
		if f.match '.iced$'
			exec "iced -c ./#{f}"
	fs.readdirSync(__dirname+'/views').forEach (f)->
		if f.match '.iced$'
			exec "iced -c --bare --runtime inline --output ./views/ ./views/#{f}"
task 'watch', 'watch and compile iced-coffee-scripts', (options) ->
	fs.readdirSync(__dirname).forEach (f)->
		if f.match '.iced$'
			exec "iced -w --output ./ ./#{f}"
	fs.readdirSync(__dirname+'/views').forEach (f)->
		if f.match '.iced$'
			exec "iced -w --bare --runtime inline --output ./views/ ./views/#{f}"