exports.getRoute = (view)->
	(req, res)->
		res.render view, { title: 'Express'}