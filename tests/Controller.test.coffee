Controller = require '../lib/Controller'
chai = require 'chai'
spies = require 'chai-spies'
chai.use spies
expect = chai.expect

describe 'Controller', ->
    controller = new Controller
    methods = [ 'main', 'before', 'after', 'handle', 'success', 'failure', 'final' ]
    they = (description, callback) ->
        it description, ->
            for method in methods
                callback method
    req = { }
    res = { }

    beforeEach ->
        req = { id: 'req' }
        res = { id: 'res', json: chai.spy(), send: chai.spy() }

        controller = new Controller
        controller.set req, res

    describe 'fields', ->
        it 'should start with null request & response objects', ->
            controller = new Controller
            expect(controller.req).to.be. null
            expect(controller.res).to.be. null

        it 'should have a settings object', ->
            settings = controller.settings
            expect(settings).to.be.an 'object'

            expect(settings.wrap).to.equal true
            expect(settings.saveApp).to.equal true

        it 'should have a _funcs object', ->
            expect(controller._funcs).to.be.an 'object'

            for method in methods
                expect(controller._funcs[method]).to.be.a 'function'

    describe 'prototype', ->
        describe 'set()', ->
            it 'should return the controller', ->
                expect( controller.set() ).to.equal controller

            it 'should set the request & response ojects', ->
                controller.set(req, res)

                expect(controller.req).to.equal req
                expect(controller.res).to.equal res

        describe 'configure()', ->
            it 'should return the controller', ->
                expect( controller.configure() ).to.equal controller

            it 'should set the settings', ->
                expect(controller.settings.wrap).to.equal true
                expect(controller.settings.saveApp).to.equal true

                controller.configure wrap: false, saveApp: false

                expect(controller.settings.wrap).to.equal false
                expect(controller.settings.saveApp).to.equal false

            it 'it should not set settings that do not exist', ->
                expect(controller.settings).not.to.have.key 'undef'

                controller.configure undef: 'foobar'

                expect(controller.settings).not.to.have.key 'undef'

        describe 'control functions', ->
            they 'should have a control function for each _func', (method)->
                expect(controller[method]).to.be.a 'function'

            they 'should return the controller', (method)->
                expect( controller[method]() ).to.equal controller

            describe 'setting the function', ->
                they 'should set the _func if the first param is a function', (method)->
                    func = ->

                    controller[method] func

                    expect(controller._funcs[method]).to.equal func

                they 'should not set the _func if the first param is a not function', (method)->
                    obj = { foo: 'bar' }

                    controller[method] obj

                    expect(controller._funcs[method]).not.to.equal obj

                they 'should not set the _func if more than one param', (method)->
                    func = ->

                    controller[method] func, json: ->

                    expect(controller._funcs[method]).not.to.equal func

                they 'should not call the _func', (method)->
                    spy = chai.spy()

                    controller[method] spy

                    expect( spy ).not.to.have.been.called

            describe 'calling the function', ->
                they 'should call the _func if not setting it', (method)->
                    spy = chai.spy()
                    controller[method] spy

                    controller[method]()

                    expect( spy ).to.have.been.called.once

                they 'should apply() the _func, setting controller as "this"', (method)->
                    func = -> expect(this).to.equal controller
                    controller[method] func

                    controller[method]()

                they 'should pass request & response objects to the _func', (method)->
                    spy = chai.spy()
                    controller.set(req, res)
                    controller[method] spy

                    controller[method]()

                    expect( spy ).to.have.been.called.with req, res

                they 'should also pass any params given along to the _func', (method)->
                    param1 = { id: 'param1' }
                    param2 = [ 'thing1', 'thing2' ]
                    spy = chai.spy()
                    controller.set(req, res)
                    controller[method] spy

                    controller[method] param1, param2

                    expect( spy ).to.have.been.called.with req, res, param1, param2

    describe '_funcs', ->
        beforeEach ->
            controller.set req, res

        describe 'main()', ->
            it 'should be set to args[0] if given', ->
                func = ->

                controller = new Controller func

                expect(controller._funcs.main).to.equal func

            it 'should call handle()', ->
                spy = controller._funcs.handle = chai.spy()

                controller._funcs.main()

                expect( spy ).to.have.been.called.once

        describe 'final()', ->
            it 'should call set(req, res)', ->
                controller.set = chai.spy()

                controller.final()

                expect( controller.set ).to.have.been.called.
                    once.with req, res

            it 'should call set(req, res) with given args if supplied', ->
                controller.set = chai.spy()
                request = { id: 'request-fake' }
                response = { id: 'response-fake' }

                controller.final request, response

                expect( controller.set ).to.have.been.called.
                    once.with request, response

            it 'should call before()', ->
                spy = controller._funcs.before = chai.spy()

                controller.final()

                expect( spy ).to.have.been.called.once


            it 'should call main()', ->
                spy = controller._funcs.main = chai.spy()

                controller.final()

                expect( spy ).to.have.been.called.once

        describe 'handle()', ->
            it 'should call failure() if err exists', ->
                spy = controller._funcs.failure = chai.spy()
                sSpy = controller._funcs.success = chai.spy()

                controller.handle {}

                expect( spy ).to.have.been.called.once
                expect( sSpy ).not.to.have.been.called

            it 'should call failure() if data does not exist', ->
                spy = controller._funcs.failure = chai.spy()
                sSpy = controller._funcs.success = chai.spy()

                controller.handle undefined, undefined

                expect( spy ).to.have.been.called.once
                expect( sSpy ).not.to.have.been.called

            it 'should call success() if err does not exist, but data does', ->
                spy = controller._funcs.success = chai.spy()
                fSpy = controller._funcs.failure = chai.spy()

                controller.handle undefined, {}

                expect( spy ).to.have.been.called.once
                expect( fSpy ).not.to.have.been.called

            it 'should pass err and data to failure()', ->
                spy = controller._funcs.failure = chai.spy()
                err = { message: 'an error' }
                data = { foo: 'bar' }

                controller.handle err, data

                expect( spy ).to.have.been.called.with req, res, err, data

            it 'should pass data to success()', ->
                spy = controller._funcs.success = chai.spy()
                data = { foo: 'bar' }

                controller.handle undefined, data

                expect( spy ).to.have.been.called.with req, res, data

            it 'should call success if err & data are not passed (args.len == 2)', ->
                sSpy = controller._funcs.success = chai.spy()
                fSpy = controller._funcs.failure = chai.spy()

                controller.handle()
                expect( sSpy ).to.have.been.called.once
                expect( fSpy ).not.to.have.been.called

        describe 'success()', ->
            it 'should call after()', ->
                spy = controller._funcs.after = chai.spy()

                controller.success()

                expect( spy ).to.have.been.called.once

            it 'should call res.json(data)', ->
                data = { d: 'data' }

                controller.success data

                expect( res.json ).to.have.been.called.
                    once.with data

        describe 'failure()', ->
            it 'should call after()', ->
                spy = controller._funcs.after = chai.spy()

                controller.failure()

                expect( spy ).to.have.been.called.once

            it 'should call res.send(404, null) if data is undefined', ->
                controller.failure undefined, undefined

                expect( res.send ).to.have.been.called.
                    once.with 404, null

            it 'should call res.send(500, {errorMessage}) if err exists', ->
                err = { toString: -> 'sample error message' }
                body = 'Something went wrong: ' + err.toString()

                controller.failure err

                expect( res.send ).to.have.been.called.
                    once.with 500, body

            it 'should call res.send(500, "An unkown error occurred.") if neither', ->
                body = 'An unknown error occurred.'

                controller.failure undefined, {}

                expect( res.send ).to.have.been.called.
                    once.with 500, body