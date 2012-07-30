fs = require 'fs'
coffee=require 'iced-coffee-script'
path=require('path')
cp=require('child_process')
os=require 'os'
watch=require 'watch'
nodeMinify=require('node-minify')


getDataURI=(filename)->
	ext=path.extname(filename).substring 1
	"data:#{contentTypes[ext]||'application/oct-stream'};base64,"+fs.readFileSync(filename).toString('base64')

contentTypes=
	jpg:'image/jpg'
	jpeg:'image/jpeg'
	png:'image/png'
	gif:'image/gif'
	bmp:'image/bmp'
	tif:'image/tif'

option '-o','--output [DIR]','fork and deploy destination'
option '-w','--watch','watch and build'
option '-v','--verbose','wanna see warnings'
option '-d','--dev','build dev-only stuff'
option '-b','--dataBase [PREFIX]','data url prefix'

verbose=undefined
exec=(cmd,cb)->
	msg=''
	if os.type().toLowerCase().indexOf('windows')!=-1
		cmd=cmd.replace /\//g,'\\'
		cmd=cmd.replace (new RegExp('\\\\\\\\','g')),'/'
	console.log "#{process.cwd()} > #{cmd}"
	c=cp.exec cmd,{stdio: 'inherit',cwd:process.cwd()}
	c.stdout.setEncoding 'utf8'
	c.stderr.setEncoding 'utf8'

	c.stdout.on 'data',(data)->
		if data? and data.trim().length
			if verbose?
				console.error data
			else
				msg+=data
	c.stderr.on 'data',(data)->
		if data? and data.trim().length
			if verbose?
				console.error data
			else
				msg+=data
	c.on 'exit',(code,sig)->
		if code!=0
			console.log "ERROR(exited with #{code})"
			console.log msg
		cb(code!=0)

copy=(f1,f2,cb)->
	if os.type().toLowerCase().indexOf('windows')!=-1
		await exec "copy #{f1} #{f2}",defer err
	else
		await exec "cp #{f1} #{f2}",defer err
	cb err

copyDir=(d1,d2,cb)->
	if !d2.match '/$'
		d2=d2+'/'
	if os.type().toLowerCase().indexOf('windows')!=-1
		await exec "xcopy #{d1} #{d2} //E //Y",defer err
	else
		await exec "cp -R #{d1} #{d2}",defer err
	cb err

task 'build', 'build everything', (options) ->
	verbose=options.verbose

	_proc=(dir,f,cb)->
		if options.dev?
			if f.match(/.jade$/)!=null and dir in ['views/']
				await exec "cp #{__dirname}/page.debug.htm ./#{dir}#{f.replace('.jade','.htm')}",defer err
				await exec "jade --out ./#{dir}/ ./#{dir}#{f}",defer err
		if f.match(/.less$/)!=null and dir in ['styles/','views/']
			await exec "lessc --include-path=./#{dir} ./#{dir}#{f} ./#{dir}#{f.replace('.less','.css')}",defer err

		if f.match(/.iced$/)!=null and dir in ['scripts/','views/']
			await exec "iced -c --output ./#{dir} --runtime inline --bare ./#{dir}#{f}",defer err


		if f.match(/.jade.js$/)!=null and dir in ['scripts/','views/']
			await fs.readFile "./#{dir}#{f}",'utf8',defer err,data
			await fs.readFile "./#{dir}#{f.replace(/.js$/,'')}",'utf8',defer err,jade
			if jade
				jade=jade.split('\n')
				i=0
				while jade[i].indexOf('-')==0
					i++
				jade=jade.slice(i).join '\n'
				jade='-'+data.split('\n').slice(1).join('')+'\r\n'+jade
				await fs.writeFile "./#{dir}#{f.replace(/.js$/,'')}",jade,'utf8',defer err

		if f.match(/.iced$/)!=null and dir in [''] and f.match(/.debug.iced$/)==null
			await exec "iced -c --output ./#{dir} ./#{dir}#{f}",defer err
		if f.match(/.debug.iced$/)!=null and dir in ['']
			await exec "iced -c --output ./#{dir} --runtime inline --bare ./#{dir}#{f}",defer err
		cb err

	_onepass=(p,root,cb)->
		await fs.readdir root+p,defer(err,files)
		for f in files
			await fs.stat path.join(root+p,f),defer(err,stat)
			if stat.isDirectory()
				await _onepass "#{p}#{f}/",root,defer err
			if stat.isFile()
				await _proc p,f,defer err
		cb err
	_watch=(p,root,cb)->

		if os.type().toLowerCase().indexOf('windows')!=-1
			dir=path.join root,p
			fs.watch dir,(e,f)->
				if f
					await _proc p,f,defer err
			await fs.readdir root+p,defer(err,files)
			for f in files
				await fs.stat path.join(root+p,f),defer(err,stat)
				if stat.isDirectory()
					await _watch "#{p}#{f}/",root,defer err
			cb err
			return
		watch.watchTree root,(f,curr,prev)->
			if (typeof(f)== "object" && prev == null && curr == null)
		    	#Finished walking the tree
		    	return
		    if curr.nlink!=0
		    	p=path.dirname f
		    	p=p.replace(new RegExp('\\\\',g),'/')+'/'
		    	f=f.substring p.length
		    	p=p.substring root.length
		    	console.log "#{p}   #{f}"
		    	await _proc p,f,defer err

	await _onepass '',__dirname+'/',defer err
	if options.watch?
		await _watch '',__dirname+'/',defer err
	else
		if err
			console.error 'NOT OK!!!!!!'
			process.exit(1)

_minify=(type,fin,fout,cb)->
	console.log "#{type} processing..."
	new nodeMinify.minify
		type:type
		fileIn:fin
		fileOut:fout
		tempPath:'crude/tmp'
		callback:cb

task 'static','compress all static resouces',(options)->
	verbose=options.verbose
	dest=options.output
	err=[]
	
	await fs.readdir __dirname+'/styles',defer(err[err.length],files)
	files=files.sort()
	await _minify 'yui-css',files.map((f)->"styles/#{f}").filter((f)->f.match /.css$/),'public/stylesheets_withoutcrude.css',defer err[err.length]

	await fs.readdir __dirname+'/scripts',defer(err[err.length],files)
	files=files.sort()
	await _minify 'gcc',files.map((f)->"scripts/#{f}").filter((f)->f.match /.js$/),'public/scripts.js',defer err[err.length]


	if err.filter((e)->e).length
		console.error 'NOT OK!!!!!!'
		process.exit(1)

task 'crude','embed the crude resources into css',(options)->
	err=[]
	await fs.readFile "#{__dirname}/public/stylesheets_withoutcrude.css",'utf8',defer(err[err.length],data)
	data=data.replace /url[\s]*[\s]*\([\s]*['|"]?[\s]*([^\)'"]+)[\s]*['|"]?[\s]*\)/g,(link,p)->
		if p.match /$http:\/\//
			return link
		p=path.join "#{__dirname}/public/",p
		p=p.replace /#.*/,''
		p=p.replace /\?.*/,''
		try
			link="url('#{getDataURI(p)}')"
			console.log "embeded #{p}"
			link
		catch error
			console.log "failed to embed #{p} (#{error.message.substring(0,30)}...)"
			link

	console.log "total size: #{data.length}"
	await fs.writeFile "#{__dirname}/public/stylesheets.css",data,'utf8',defer err[err.length]

	if err.filter((e)->e).length
		console.error 'NOT OK!!!!!!'
		process.exit(1)

task 'deploy','deploy the application',(options)->
	verbose=options.verbose
	dest=options.output
	err=[]
	
	console.log "deploying to #{dest}"

	await exec "mkdir #{dest}",defer()
	await exec "mkdir #{dest}/views",defer()

	await copy "./*.js","#{dest}/",defer err[err.length]
	await copyDir "./node_modules","#{dest}/node_modules",defer err[err.length]
	await copyDir "./public","#{dest}/public",defer err[err.length]

	await copy "./views/*.js","#{dest}/views/",defer err[err.length]
	await copy "./views/*.jade","#{dest}/views/",defer err[err.length]

	if err.filter((e)->e).length
		console.error 'NOT OK!!!!!!'
		process.exit(1)

task 'fork', 'safely fork myself to a current project', (options) ->
	verbose=options.verbose
	dest=options.output
	err=[]

	console.log "forking to #{dest}"
	await exec "mkdir #{dest}/",defer()
	await exec "mkdir #{dest}/views",defer()
	await exec "mkdir #{dest}/libs",defer()


	await copy "./app.iced","#{dest}/app.iced",defer err[err.length]
	await copy "./routes.iced","#{dest}/routes.iced",defer err[err.length]
	await copy "./Cakefile","#{dest}/Cakefile",defer err[err.length]
	await copy "./package.json","#{dest}/package.json",defer err[err.length]
	await copy "./page.debug.iced","#{dest}/page.debug.iced",defer err[err.length]
	await copy "./build.cmd","#{dest}/build.cmd",defer err[err.length]
	await copy "./build.sh","#{dest}/build.sh",defer err[err.length]

	await copy "./libs/jade-bundle.js","#{dest}/libs/jade-bundle.js",defer err[err.length]
	await copy "./libs/jquery.js","#{dest}/libs/jquery.js",defer err[err.length]
	await copy "./libs/jquery-deparam.js","#{dest}/libs/jquery-deparam.js",defer err[err.length]



	if err.filter((e)->e).length
		console.error 'NOT OK!!!!!!'
		process.exit(1)

task 'staticify','staticalize our data',(options)->
	if !options.dataBase?
		console.log 'must specify option --dataBase'
		return
	await fs.readFile 'actionList.txt','utf8',defer err,actions
	actions=actions.split('\n').map (action)->
		action.replace(/#.*/,'').trim()
	actions=actions.filter (action)->
		action.length
	for action in actions
		filename=action
		if filename.indexOf('/')!=-1
			filename=filename.match(/\/.+$/)[0]
		if filename.indexOf('?')!=-1
			filename=filename.match(/(.*)\?/)[1]
		dataBase=options.dataBase.replace(/\//g,'//')
		await exec "curl \"#{dataBase}#{action}\" -o datasample.jsonp/#{filename} -c datasample.jsonp/cookies.txt -b datasample.jsonp/cookies.txt",defer err