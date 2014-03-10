var express = require('express')
    , mongoose = require('mongoose')
    , Controller = require('./Controller.js');
var app = express();

module.exports = function(Schema) {
    if(typeof Schema === 'string') {
        Schema = mongoose.model(Schema);
    }
    var verbs = [ 'get', 'post', 'delete', 'put', 'patch' ];
    var c = { controllers: {}, _resourceController: true,
        app: function() { return require('./generateApp.js')(this); }
    };

    function setCtrlFunc(verb) {
        return function(path, func) {
            if( !c.controllers[verb][path] ) { c.controllers[verb][path] = new Controller(func) }

            return c.controllers[verb][path];
        };
    }
    for(var i = 0, len = verbs.length; i < len; i++) {
        var verb = verbs[i];
        c.controllers[verb] = {};
        c[verb] = setCtrlFunc(verb);
    }

    // ====================
    // === Set defaults
    // ====================
    c.controllers.get['/'] = require('./defaultControllers').getAll(Schema);
    c.controllers.post['/'] = require('./defaultControllers').create(Schema);
    c.controllers.get['/:id'] = require('./defaultControllers').getOne(Schema);
    c.controllers.delete['/:id'] = require('./defaultControllers').delete(Schema);
    c.controllers.put['/:id'] = require('./defaultControllers').put(Schema);
    c.controllers.patch['/:id'] = require('./defaultControllers').patch(Schema);

    return c;
}