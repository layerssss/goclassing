#
#* window.jQuery
#* jade
#

actions=[]

_actionCur=0

data=
	params:$.deparam(location.search.substring(1))

_file=location.href
i=_file.indexOf('?')
_file=_file.substring(0,if i==-1 then _file.length else i)
i=_file.indexOf('#')
_file=_file.substring(0,if i==-1 then _file.length else i)
filename=_file.substring(_file.lastIndexOf('/')+1)
filename=filename.substring(0,filename.lastIndexOf('.'))




document.write('<script src="'+filename+'.js"></script>');

_ajax=(opt,cb)->
	opt.success=cb
	$.ajax opt

dataBase='/'
reload=()->
	for action in actions
		opt=
			dataType:'jsonp'
			jsonpCallback:'dSet'
			converters:
				'* text':window.String
				'text json':(d)->
					eval 'haha='+d
			error:(a,b,c)->
				console.log "error in action:"
				console.log action
				console.log a
				console.log b
				console.log c
		for k,v of action
			opt[k]=v
		d=null
		if opt.url!=null
			if typeof(opt.url)=='function'
				opt.url=opt.url.call data
			opt.url=dataBase+opt.url
			await _ajax opt,defer d
		action.success.call data,d
	await _ajax {url:"#{filename}.jade?t=#{new Date()}",dataType:'text'},defer template
	$('body').html(jade.compile(template,{filename:filename+'.jade'})(data).match(/<body>((.|\r|\n)*)<\/body>/)[1])[0].onload=()->
		$(window).trigger 'pageLoad'

jump=(url)->
	location.href=url

$ ()->
	reload()