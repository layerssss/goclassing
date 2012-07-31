
exports.getRoute = (view,dataDefault)->	
	fs=require 'fs'
	http=require 'http'
	vm = require 'vm'
	nurl=require 'url'
	if typeof(dataDefault)!='string'
		dataDefault=JSON.stringify dataDefault
	_jsonp=(url,cookie,cb)->
		data=''
		opt=nurl.parse url+'&callback=dSet'
		opt.headers=
			Cookie:cookie
		req=http.request opt,(res)->
			if(res.statusCode!=200)
				cb {status:500,message:"http error:#{res.statusCode}",url:url}
				return;
			res.setEncoding 'utf8'
			res.on 'data',(chunk)->
				data+=chunk;
			res.on 'end',()->
				d={}
				dSet=(theD)->
					d=theD
					d._jsonpset=true
				try
					eval(data)
					if !d._jsonpset?
						throw new Error()
				catch e
					cb {status:500,message:'JSONP format error',url:url},null
					return
				if d.status&&d.status!=200
					d.url=url
					cb d,null
					return
				d.setCookie=res.headers['set-cookie']
				cb null,d
		req.on 'error',(e)->
			cb {status:500,message:'network error:'+e.message,url:url},null
		req.end()


	(req, res)->
		await fs.readFile "#{__dirname}/views/#{view}.js",'utf8',defer(err,js)
		data=JSON.parse(dataDefault)
		setCookie=''
		data.runat='server'
		data.params={}
		for k,v of req.params
			data.params[k]=v
		data.view=view
		data.url=nurl.parse req.url
		actions=[]
		eval js
		for a in actions
			jsonp=null
			if a.url!=null
				if typeof(a.url)=='function'
					a.url=a.url.call data
				await _jsonp data.dataBase+a.url,req.headers.cookie,defer(err,d)
				if err
					data.error=err
					res.render 'error',data
					return
				setCookie+=if d.setCookie? then d.setCookie else ''
			a.success.call data,d,data
		if setCookie.length
			res.setHeader 'Set-Cookie',setCookie
		res.setHeader 'Cache-Control','no-cache'
		res.render view,data