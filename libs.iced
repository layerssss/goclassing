module.exports.get=(callback)->
	http=require('http')
	fs=require('fs')
	console.log 'getting libs'
	libs={'jquery.js':'http://code.jquery.com/jquery-git.js'}
	data={}
	await 
		for file,url of libs
			((file,url,cb)->
				console.log "GET #{url}"
				await http.get url,defer res
				console.log "#{res.statusCode} #{url}"
				data[file]=''
				res.on 'data',(chuck)->
					data[file]+=chuck
				res.on 'end',cb) file,url,defer err
	for file,content of data
		await fs.writeFile __dirname+'/libs/'+file,defer err
		console.log "saved to #{file}"