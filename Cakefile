fs = require 'fs'
coffee=require 'iced-coffee-script'
task 'build', 'compile iced-coffee-scripts', (options) ->
	fs.readdirSync(__dirname).forEach (file)->
		if file.match '.iced$'
			fs.readFile __dirname+'/'+file,(err,data)->
				fs.writeFile __dirname+'/'+file.substring(0,file.length-4)+'js',coffee.compile String(data)