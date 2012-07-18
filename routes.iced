exports.getRoute = (view)->
	(req, res)->
		res.render view, { params:req.params}