var express = require('express')
    , mongoose = require('mongoose')
    , generateController = require('./generateController.js');

module.exports = function() {
    var app = express(),
        ResourceController = arguments[0]._resourceController === true ? arguments[0] : generateController(arguments[0]),
        controllers = ResourceController.controllers,
        defaults = {
            get: { '/': true, '/:id': true },
            post: { '/': true },
            delete: { '/:id': true },
            put: { '/:id': true },
            patch: { '/:id': true }
        }

    function wrap(controller) {
        if(controller.settings.saveApp === true && controller.settings.wrap === true) {
            controller.app = app;
        }
        app[verb](path, controller.settings.wrap !== true ?
            controller._funcs.final :
            function(req, res){
                controller._funcs.final.apply(controller, arguments);
            }
        );
    }

    for(var verb in controllers) {
        var paths = controllers[verb];
        for(var path in paths) {
            if( defaults[verb] && defaults[verb][path] ) {
                continue;
            }
            wrap(controllers[verb][path]);
        }
    }

    for(var verb in defaults) {
        var paths = controllers[verb];
        for(var path in paths) {
            wrap(controllers[verb][path]);
        }
    }

    return app;
}