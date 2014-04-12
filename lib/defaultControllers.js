var Controller = require('./Controller.js');
var m = module.exports = {};

m.getAll = function(Schema) {
    var controller = new Controller(function(req, res) {
        Schema.find({}, controller.handle);
    });

    return controller;
}

m.getOne = function(Schema) {
    var controller = new Controller(function(req, res){
        Schema.findOne({ _id: req.param('id') }, controller.handle)
    });

    return controller;
}

m.create = function(Schema) {
    var controller = new Controller(function(req, res) {
        new Schema( req.body ).save(controller.handle)
    })
        .failure(function(req, res, err) {
            if(err) { res.send(500, 'Something went wrong: ' + err.toString() ) }
            else { res.send(500, 'An unknown error occurred.') }
        });

    return controller;
}

m.delete = function(Schema) {
    var controller = new Controller(function(req, res) {
        Schema.remove({ _id: req.param('id') }, controller.handle);
    })
        .handle(function(req, res, err, documents, quantity) {
            if(err || !documents || quantity == 0) { controller.failure(err, documents, quantity) }
            else { controller.success() }
        })
        .success(function(req, res) {
            res.send(204, null);
        })
        .failure(function(req, res, err, documents, quantity) {
            if(err) { res.send(500, 'Something went wrong: ' + err.toString() ) }
            else if( !documents || quantity == 0) { res.send(404, null) }
            else { res.send(500, 'An unknown error occurred.') }
        });

    return controller;
}

m.put = function(Schema) {
    var controller = new Controller(function(req, res) {
        Schema.findOne({ _id: req.param('id') }, function(err, document) {
            if(err) { res.send(500, 'Something went wrong: ' + err.toString() ) }
            else if(!document ) { res.send(404, null) }
            else {
                for(var k in req.body) {
                    if( req.body && req.body.hasOwnProperty(k) && document.schema.paths.hasOwnProperty(k) ) {
                        document[k] = req.body[k];
                    }
                }
                for( var k in document.schema.paths ) {
                    if( req.body && !req.body.hasOwnProperty(k) && k != '__v' && k != '_id' ) {
                        document[k] = undefined;
                    }
                }

                document.save(function(err, savedDocument) {
                    controller.handle(err, savedDocument);
                });
            }
        });
    })
        .failure(function(req, res, err) {
            if(err) { res.send(500, 'Something went wrong: ' + err.toString() ) }
            else { res.send(500, 'An unknown error occurred.') }
        });

    return controller;
}

m.patch = function(Schema) {
    var controller = new Controller(function(req, res) {
        Schema.findOne({ _id: req.param('id') }, function(err, document) {
            if(err) { res.send(500, 'Something went wrong: ' + err.toString() ) }
            else if(!document) { res.send(404, null) }
            else {
                for(var k in req.body) {
                    if( req.body && req.body.hasOwnProperty(k) && document.schema.paths.hasOwnProperty(k) ) {
                        document[k] = req.body[k];
                    }
                }
//
                document.save(function(err, savedDocument) {
                    controller.handle(err, savedDocument);
                });
            }
        })
    })
        .failure(function(req, res, err) {
            if(err) { res.send(500, 'Something went wrong: ' + err.toString() ) }
            else { res.send(500, 'An unknown error occurred.') }
        });

    return controller;
}