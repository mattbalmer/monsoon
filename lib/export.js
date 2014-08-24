var express = require('express');
var m = module.exports = {};

function assign(router, verb, path, controller) {
    controller.router = router;

    router[verb](path, function(req, res) {
        controller._funcs.final.apply(controller, arguments);
    });
}

var defaults = {
    'get': [ '/', '/:id' ],
    'post': [ '/' ],
    'put': [ '/:id' ],
    'patch': [ '/:id' ],
    'delete': [ '/:id' ]
};

m.toExpressRouter = function(router) {
    var e = express.Router();

    for(var verb in router.controllers) {
        var paths = router.controllers[verb];

        for(var path in paths) {
            // Only assign if the controller does not exist in the defaults
            if(!~defaults[verb].indexOf(path))
                assign(e, verb, path, paths[path]);
        }
    }

    // Assign default controllers after custom ones.
    for(var verb in defaults) {
        var paths = defaults[verb];

        for(var i in paths) {
            var path = paths[i];

            assign(e, verb, path, router.controllers[verb][path]);
        }
    }

    return e;
};