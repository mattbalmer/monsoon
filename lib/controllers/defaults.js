var Controller = require('./../Controller')
    , utils = require('./../utils');
var m = module.exports = {};

m.getAll = function(Schema) {
    return new Controller(function(req, res) {
        var c = this;

        c.find(req)
            .then(function(docs) {
                if(!docs)
                    c.failure(res, 404, null);
                else
                    c.success(res, 200, docs);
            })
            .catch(function(err) {
                c.failure(res, 500, err);
            });
    })
        .set('find', function() {
            return Schema.findQ({})
        });
};

m.getOne = function(Schema) {
    return new Controller(function(req, res) {
        var c = this;

        c.find(req)
            .then(function(docs) {
                if(!docs)
                    c.failure(res, 404, null);
                else
                    c.success(res, 200, docs);
            })
            .catch(function(err) {
                c.failure(res, 500, err);
            });
    })
        .set('find', function(req) {
            return Schema.findByIdQ(req.params.id)
        });
};

m.create = function(Schema) {
    return new Controller(function(req, res) {
        var c = this;

        c.save(req)
            .then(function(docs) {
                if(!docs)
                    c.failure(res, 500, null);
                else
                    c.success(res, 201, docs);
            })
            .catch(function(err) {
                if(err.code == 11000)
                    return c.failure(res, 409, err);

                c.failure(res, 500, err);
            });
    })
        .set('save', function(req) {
            return Schema.createQ(req.body);
        });
};

m.remove = function(Schema) {
    return new Controller(function(req, res) {
        var c = this;

        c.save(req)
            .then(function(document) {
                if(document == null)
                    c.failure(res, 404, null);
                else
                    c.success(res, 204, null);
            })
            .catch(function(err) {
                c.failure(res, 500, err);
            });
    })
        .set('save', function(req) {
            return Schema.findByIdAndRemoveQ(req.params.id);
        });
};

m.replace = function(Schema) {
    return new Controller(function(req, res) {
        var c = this;

        c.find(req)
            .then(function(document) {
                if(!document) {
                    c.failure(res, 404, null);
                } else {
                    var newDoc = utils.overwriteModel(document, req.body);
                    return c.save(newDoc);
                }
            })
            .then(function(document) {
                c.success(res, 200, document);
            })
            .catch(function(err) {
                c.failure(res, 500, err);
            });
    })
        .set('find', function(req) {
            return Schema.findByIdQ(req.params.id)
        })
        .set('save', function(document) {
            return document.saveQ();
        });
};

m.update = function(Schema) {
    return new Controller(function(req, res) {
        var c = this;

        c.find(req)
            .then(function(document) {
                if(!document) {
                    c.failure(res, 404, null);
                } else {
                    var newDoc = utils.extendModel(document, req.body);
                    return c.save(newDoc);
                }
            })
            .then(function(document) {
                c.success(res, 200, document);
            })
            .catch(function(err) {
                c.failure(res, 500, err);
            });
    })
        .set('find', function(req) {
            return Schema.findByIdQ(req.params.id)
        })
        .set('save', function(document) {
            return document.saveQ();
        });
};