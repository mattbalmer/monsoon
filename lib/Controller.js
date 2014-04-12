var Controller = module.exports = function(main) {
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
            if(arguments.length == 2 || (!err && data) ) controller.success(data)
            else controller.failure(err, data)
        },
        success: function(req, res, data) {
            res.json(data);
            controller.after();
        },
        failure: function(req, res, err, data) {
            if(err) { res.send(500, 'Something went wrong: ' + err.toString() ) }
            else if( data == undefined ) { res.send(404, null) }
            else { res.send(500, 'An unknown error occurred.') }
            controller.after();
        },
        final: function(autoReq, autoRes, req, res) {
            controller.set(req || autoReq, res || autoRes);
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
        if( func && typeof func === 'function' && arguments.length == 1 ) {
            s._funcs[stage] = func;
        } else {
            // Else, call it with the given arguments, and the request and response
            var params = [s.req, s.res];
            params = params.concat(Array.prototype.slice.call(arguments));

            s._funcs[stage].apply(s, params);
        }

        //Either way, return the Controller so chaining can happen
        return s;
    }
}

for(var stage in new Controller()._funcs) {
    generateCtrlFunc(stage);
}

