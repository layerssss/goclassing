module.exports=(app,routes)->
	app.get '/', routes.getRoute('index')