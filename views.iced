module.exports=(app,routes)->
	app.get '/notready', routes.getRoute('notready')
	app.get '*', (req,res)->
		res.writeHead 302, 
  			'Location': '/notready'
  		res.end()
