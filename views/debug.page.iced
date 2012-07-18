#开发环境下的页面引擎,加载所有资源
#需要:
#
#* window.jQuery
#* jade
#

#保存动作的数组
actions=[]

#下一步该执行的动作的索引
_actionCur=0

#渲染Jade模版所用的数据
data=
	params:$.deparam(location.search.substring(1))

#当前htm文件的文件名
_file=location.href
i=_file.indexOf('?')
_file=_file.substring(0,if i==-1 then _file.length else i)
i=_file.indexOf('#')
_file=_file.substring(0,if i==-1 then _file.length else i)
filename=_file.substring(_file.lastIndexOf('/')+1)
filename=filename.substring(0,filename.length-4)

#加载页面less
document.write('<link rel="stylesheet/less" type="text/plain" href="'+filename+'.css"></link>')


#将加载页面jade作为第一个action
actions.push
	url:"views/layout.jade?t=#{new Date()}"
	dataType:'text'
	success:(j)->
		this.jade=j.replace /block content/g,'| !{content}'
actions.push
	url:"views/#{filename}.jade?t=#{new Date()}"
	dataType:'text'
	success:(j)->
		j=j.replace /extends layout/g,''
		j=j.replace /block content/g,''
		j=j.replace /\n\t/g,''
		this.content=j

#加载页面js
document.write('<script src="'+filename+'.js"></script>');

_ajax=(opt,cb)->
	opt.success=cb
	$.ajax opt

dataBase='../'
#重绘页面(相当于刷新页面)
reload=()->
	for action in actions
		opt=
			dataType:'json'
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
		if typeof(opt.url)=='function'
			opt.url=opt.url.call data
		opt.url=dataBase+opt.url
		await _ajax opt,defer d
		action.success.call data,d
	data.content=jade.compile(data.content)(data)
	$('body').html(jade.compile(data.jade)(data).match(/<body>((.|\r|\n)*)<\/body>/)[1])
#跳转页面(相当于location.href='XXX')
#用于在js中手动跳转页面时使用
jump=(url)->
	location.href=url

#初始化,加载布局,并进行第一次reload
$ ()->
	reload()

