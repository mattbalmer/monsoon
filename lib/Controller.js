var Controller = module.exports = function(main) {
    this.req = null;
    this.res = null;

    this.settings = {
        wrap: true,
        saveApp: true
    };

    var controller = this;
    this._funcs = {
        main: main,
        find: function(){},
        save: function(){},
        success: function(res, code, data) {
            if(arguments.length == 2) {
                data = code;
                code = 200;
            }

            res.json(code, data);
        },
        failure: function(res, code, err) {
            if(arguments.length == 2) {
                err = code;
                code = 500;
            }

            var message = err === null ? null
                : (err || 'An unknown error occurred').toString();

            res.send(code, message);
        },
        final: function(req, res) {
            controller.req = req;
            controller.res = res;
            controller.main(req, res);
        }
    };
};

Controller.prototype.set = function(req, res) {
    this.req = req;
    this.res = res;

    return this;
};

Controller.prototype.configure = function(settings) {
    for(var k in settings) {
        if(settings.hasOwnProperty(k) && this.settings.hasOwnProperty(k)) {
            this.settings[k] = settings[k];
        }
    }
    return this;
};

Controller.prototype.set = function(stage, func) {
    this._funcs[stage] = func;
    console.log('set', stage);

    // Return the Controller so chaining can happen
    return this;
};

function generateCtrlFunc(stage) {
    Controller.prototype[stage] = function(func) {
        var s = this;

        // Else, call it with the given arguments, and the request and response
        var params = [s.req, s.res];
        params = params.concat(Array.prototype.slice.call(arguments));

        console.log('call', stage);

        // Return whatever the function returns
        return s._funcs[stage].apply(s, arguments);
    }
}

for(var stage in new Controller()._funcs) {
    generateCtrlFunc(stage);
}