
cp=require('child_process')
exec=(cmd,cb)->
	c=cp.exec cmd,{stdio: 'inherit'}
	c.stdout.on 'data',(data)->
		if data? and data.length
			console.log data
	c.stderr.on 'data',(data)->
		if data? and data.length
			console.error data
	c.on 'exit',if cb? then cb else ()->

module.exports.get=(callback)->
	http=require('http')
	fs=require('fs')
	console.log 'getting libs'
	libs={
		'jquery.js':'http://code.jquery.com/jquery-git.js'
		'jade.js':'https://raw.github.com/visionmedia/jade/master/jade.js'
	}
	data={}
	for file,url of libs
		console.log "GET #{url}"
		await exec "curl #{url} -s -S -o libs/#{file}",defer err
		console.log "OK #{url}"