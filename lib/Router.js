var mongoose = require('mongoose-q')()
    , Controller = require('./Controller')
    , exportFuncs = require('./export')
    , defaults = require('./controllers/defaults');

var Router = function() {
    this.controllers = {};
};

Router.prototype.export = function() {
    return exportFuncs.toExpressRouter(this);
};

// == Generate router.get, router.post, etc...
([ 'get', 'post', 'delete', 'put', 'patch' ]).forEach(function(verb) {
    Router.prototype[verb] = function(path, func) {
        if(func) {
            if(typeof this.controllers[verb] === 'undefined') {
                this.controllers[verb] = {};
            }

            this.controllers[verb][path] = new Controller(func);
        }

        return this.controllers[verb][path];
    };
});

module.exports = {
    Router: Router,

    router: function(Schema) {
        var router = new Router();

        // == Set default routes
        router.controllers.get = {};
        router.controllers.post = {};
        router.controllers.put = {};
        router.controllers.patch = {};
        router.controllers.delete = {};

        router.controllers.get['/'] = defaults.getAll(Schema);
        router.controllers.post['/'] = defaults.create(Schema);
        router.controllers.get['/:id'] = defaults.getOne(Schema);
        router.controllers.delete['/:id'] = defaults.remove(Schema);
        router.controllers.put['/:id'] = defaults.replace(Schema);
        router.controllers.patch['/:id'] = defaults.update(Schema);

        return router;
    }
};