var Controller = function(main) {
    this.req = null;
    this.res = null;

    this.settings = {
        wrap: true,
        saveApp: true
    }

    var controller = this;
    this._funcs = {
        main: main || function() {
            controller.handle();
        },
        before: function(){},
        after: function(){},
        handle: function(req, res, err, data) {
            if(err || !data ) { controller.failure(err, data) }
            else { controller.success(data) }
        },
        success: function(req, res, documents) {
            res.json(documents);
            controller.after();
        },
        failure: function(req, res, err, data) {
            if( data == undefined ) { res.send(404, null) }
            else if(err) { res.send(500, 'Something went wrong: ' + err.toString() ) }
            else { res.send(500, 'An unknown error occurred.') }
        },
        final: function(req, res) {
            controller.set(req, res);
            controller.before();
            controller.main();
        }
    };
}
Controller.prototype.set = function(req, res) {
    this.req = req;
    this.res = res;

    return this;
}
Controller.prototype.configure = function(settings) {
    for(var k in settings) {
        if(settings.hasOwnProperty(k) && this.settings.hasOwnProperty(k)) {
            this.settings[k] = settings[k];
        }
    }
    return this;
}

function generateCtrlFunc(stage) {

    Controller.prototype[stage] = function(func) {
        var s = this;

        // If a function is given, set it
        if( func && typeof func === 'function' ) {
            s._funcs[stage] = func;
        } else {
            // Else, call it with the given arguments, and the request and response
            var params = [s.req, s.res];
            params = params.concat(Array.prototype.slice.call(arguments));
            s._funcs[stage].apply(s, params);
        }

        // Either way, return the Controller so chaining can happen
        return s;
    }
}

for(var stage in new Controller()._funcs) {
    generateCtrlFunc(stage);
}

module.exports = Controller;