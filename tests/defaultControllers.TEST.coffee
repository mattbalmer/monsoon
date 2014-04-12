Controller = require '../lib/Controller'
defaultControllers = require '../lib/defaultControllers'
chai = require 'chai'
spies = require 'chai-spies'
expectArgs = require './helpers'
chai.use spies
expect = chai.expect

# Init
@keys = []
for key, func of defaultControllers
    @keys.push key

they = (description, callback) =>
    it description, =>
        callback method for method in @keys

describe 'defaultControllers chai', ->
    beforeEach ->
        @Schema = =>
            return @Schema
        @Schema = chai.spy @Schema
        @Schema.find = chai.spy()
        @Schema.findOne = chai.spy()
        @Schema.save = chai.spy()
        @Schema.remove = chai.spy()

        @req =
            param: (key)-> key
        @res =
            json: chai.spy()
            send: chai.spy()
            body:
                foo: 'bar'

    describe 'all controllers', ->
        they 'should all return a controller object', (key)->
            controller = defaultControllers[key]()

            expect(controller).to.be.an.instanceof Controller

    describe 'getAll controller', ->
        beforeEach ->
            @controller = defaultControllers.getAll @Schema

        it 'should call Schema.find with an empty object and callback', ->
            @controller.main()

            expect( @Schema.find ).to.have.been.called.
                once.with {}

        it 'should call controller.handle() with the Mongoose response', ->
            @controller.handle = chai.spy()
            err = message: 'an error obj'
            documents = [ foo: 'bar' ]
            @Schema.find = (filter, callback)->
                callback err, documents

            @controller.main()

            expect( @controller.handle ).to.have.been.called
                .once.with err, documents

    describe 'getOne controller', ->
        beforeEach ->
            @controller = defaultControllers.getOne @Schema
            @controller.set @req, @res

        it 'should call Schema.findOne with a filter object', ->
            filter =
                _id: 'id'

            @controller.main()

            expect( @Schema.findOne ).to.have.been.called
                .once.with filter

        it 'Schema.findOne should call the callback', ->
            @controller.handle = chai.spy()
            err = message: 'an error obj'
            documents = [ foo: 'bar' ]
            @Schema.findOne = (filter, callback)->
                callback err, documents

            @controller.main()

            expect( @controller.handle ).to.have.been.called
                .once.with err, documents

    describe 'create controller', ->
        beforeEach ->
            @controller = defaultControllers.create @Schema
            @controller.set @req, @res

        it 'should call new Schema(req.body)', ->
            @controller.main()

            expect( @Schema ).to.have.been.called
                .once.with @req.body

        it 'should call save on the Schema instance', ->
            @controller.main()

            expect( @Schema.save ).to.have.been.called
                .once

        it 'should call the callback', ->
            @controller.handle = chai.spy()
            err = message: 'an error obj'
            documents = [ foo: 'bar' ]
            @Schema.save = (callback)->
                callback err, documents

            @controller.main()

            expect( @controller.handle ).to.have.been.called
                .once.with err, documents

        describe 'custom failure() func', ->
            it 'should still send 500, "something went wrong: {errorMessage} if err exists', ->
                err = message: 'an error obj'
                body = 'Something went wrong: ' + err.toString()

                @controller.failure err

                expect( @res.send ).to.have.been.called
                    .once.with 500, body

            it 'should send 500, "An unknown error occurred." if err does not exist (instead of 404)', ->
                body = 'An unknown error occurred.'

                @controller.failure()

                expect( @res.send ).to.have.been.called
                    .once.with 500, body

    describe 'delete controller', ->
        beforeEach ->
            @controller = defaultControllers.delete @Schema
            @controller.set @req, @res

        it 'should call Schema.remove with an id filter', ->
            filter = _id : 'id'

            @controller.main()

            expect( @Schema.remove ).to.have.been.called
                .once.with filter

        it 'should call the callback', ->
            @controller.handle = chai.spy()
            err = message: 'an error obj'
            documents = [ foo: 'bar' ]
            quantity = 1
            @Schema.remove = (filter, callback)->
                callback err, documents, quantity

            @controller.main()

            expect( @controller.handle ).to.have.been.called
                .once.with err, documents, quantity

        describe 'custom handle() func', ->
            beforeEach ->
                @controller.failure = chai.spy()
                @controller.success = chai.spy()

            it 'should call failure() if err exists', ->
                err = message: 'an error obj'
                documents = [ foo: 'bar' ]
                quantity = 1

                @controller.handle err, documents, quantity

                expect( @controller.failure ).to.have.been.called
                    .once.with err, documents, quantity
                expect( @controller.success ).not.to.have.been.called()

            it 'should call failure() if documents does not exist', ->
                err = undefined
                documents = undefined
                quantity = 1

                @controller.handle err, documents, quantity

                expect( @controller.failure).to.have.been.called.once
                expectArgs( @controller.failure ).to.have.been err, documents, quantity
                expect( @controller.success ).not.to.have.been.called()

            it 'should call failure() if quantity is not 1', ->
                err = undefined
                documents = {}
                quantity = 0

                @controller.handle err, documents, quantity

                expect( @controller.failure).to.have.been.called.once
                expectArgs( @controller.failure ).to.have.been err, documents, quantity
                expect( @controller.success ).not.to.have.been.called()

            it 'should call success otherwise', ->
                err = undefined
                documents = {}
                quantity = 1

                @controller.handle err, documents, quantity

                expect( @controller.success ).to.have.been.called.once
                expect( @controller.failure ).not.to.have.been.called()

        describe 'custom success() func', ->
            it 'should call json.send(204, null)', ->
                @controller.success()

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 204, null

        describe 'custom failure() func', ->
            it 'if err, send(500, {somethingwentwrong})', ->
                err = { message: 'generic error message' }
                body = 'Something went wrong: ' + err.toString()

                @controller.failure err

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 500, body

            it 'if err does not exist, and neither does documents, send(404, null)', ->
                @controller.failure undefined, undefined

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 404, null

            it 'if err does not exist, but documents does and quantity > 0, send(500, {unknown})', ->
                @controller.failure undefined, {}, 1

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 500, 'An unknown error occurred.'

    describe 'put controller', ->
        savedDoc = {}
        document = {}
        saveErr = message: 'onSave error'

        beforeEach ->
            @controller = defaultControllers.put @Schema
            @controller.set @req, @res

            savedDoc = document
            document =
                foo: 'sbar'
                save: chai.spy (callback) ->
                    callback saveErr, savedDoc
                schema:
                    paths:
                        foo: 'String'
                        name: 'String'
                        price: 'Integer'

        it 'should call Schema.findOne with the ID param', ->
            @Schema.findOne = chai.spy (filter, callback)->
                callback undefined, document

            @controller.main()

            expect( @Schema.findOne ).to.have.been.called.once
                .with _id: @req.param('id')

        describe 'Schema.findOne error cases', ->
            it 'should call res.send(500, {errmsg} if err exists', ->
                err = message: 'an error obj'
                @Schema.findOne = chai.spy (filter, callback)->
                    callback err, document

                @controller.main()

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 500, 'Something went wrong: ' + err.toString()

            it 'should call res.send(404, null) if document does not exist', ->
                @Schema.findOne = chai.spy (filter, callback)->
                    callback undefined, undefined

                @controller.main()

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 404, null

        describe 'Schema.findOne success case', ->
            beforeEach ->
                @Schema.findOne = chai.spy (filter, callback)->
                    callback undefined, document
                @controller.handle = chai.spy()

            it 'should call doc.save', ->
                @controller.main()

                expect( document.save ).to.have.been.called.once

            it 'should call controller.handle(err, savedDocument)', ->
                @controller.main()

                expect( @controller.handle ).to.have.been.called.once
                expectArgs( @controller.handle ).to.have.been saveErr, savedDoc

            describe 'document model updates', ->
                it 'should put all props in the Schema & req.body on document', ->
                    @req.body =
                        foo: 'newfoo'
                        name: 'MY NAME HERE'
                        doesNotExist: 'huehue'

                    @controller.main()

                    expect( document.doesNotExist ).to.equal undefined
                    expect( document.foo ).to.equal 'newfoo'
                    expect( document.name ).to.equal 'MY NAME HERE'

                it 'should strip properties that are not set on req.body (and arent __v or _id)', ->
                    document.name = 'Initial Name'
                    document.price = 2
                    document._id = 'somehashhere'
                    document.__v = 1

                    @req.body =
                        foo: 'newfoo'

                    expect( document.name ).to.equal 'Initial Name'
                    expect( document.price ).to.equal 2
                    expect( document._id ).to.equal 'somehashhere'
                    expect( document.__v ).to.equal 1

                    @controller.main()

                    expect( document.name ).to.equal undefined
                    expect( document.price ).to.equal undefined
                    expect( document._id ).to.equal 'somehashhere'
                    expect( document.__v ).to.equal 1

        describe 'failure()', ->
            it 'should call res.send(500, {errmsg}) if err exists', ->
                err = message: "it's dead, Jim"

                @controller.failure err

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 500, 'Something went wrong: ' + err.toString()

            it 'should call res.send(500, {unknown}) if err does not exist', ->
                @controller.failure()

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 500, 'An unknown error occurred.'

    describe 'patch controller', ->
        savedDoc = {}
        document = {}
        saveErr = message: 'onSave error'

        beforeEach ->
            @controller = defaultControllers.patch @Schema
            @controller.set @req, @res

            savedDoc = document
            document =
                foo: 'sbar'
                save: chai.spy (callback) ->
                    callback saveErr, savedDoc
                schema:
                    paths:
                        foo: 'String'
                        name: 'String'
                        price: 'Integer'

        it 'should call Schema.findOne with the ID param', ->
            @Schema.findOne = chai.spy (filter, callback)->
                callback undefined, document

            @controller.main()

            expect( @Schema.findOne ).to.have.been.called.once
                .with _id: @req.param('id')

        describe 'Schema.findOne error cases', ->
            it 'should call res.send(500, {errmsg} if err exists', ->
                err = message: 'an error obj'
                @Schema.findOne = chai.spy (filter, callback)->
                    callback err, document

                @controller.main()

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 500, 'Something went wrong: ' + err.toString()

            it 'should call res.send(404, null) if document does not exist', ->
                @Schema.findOne = chai.spy (filter, callback)->
                    callback undefined, undefined

                @controller.main()

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 404, null

        describe 'Schema.findOne success case', ->
            beforeEach ->
                @Schema.findOne = chai.spy (filter, callback)->
                    callback undefined, document
                @controller.handle = chai.spy()

            it 'should call doc.save', ->
                @controller.main()

                expect( document.save ).to.have.been.called.once

            it 'should call controller.handle(err, savedDocument)', ->
                @controller.main()

                expect( @controller.handle ).to.have.been.called.once
                expectArgs( @controller.handle ).to.have.been saveErr, savedDoc

            describe 'document model updates', ->
                it 'should put all props in the Schema & req.body on document', ->
                    @req.body =
                        foo: 'newfoo'
                        name: 'MY NAME HERE'
                        doesNotExist: 'huehue'

                    @controller.main()

                    expect( document.doesNotExist ).to.equal undefined
                    expect( document.foo ).to.equal 'newfoo'
                    expect( document.name ).to.equal 'MY NAME HERE'

        describe 'failure()', ->
            it 'should call res.send(500, {errmsg}) if err exists', ->
                err = message: "it's dead, Jim"

                @controller.failure err

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 500, 'Something went wrong: ' + err.toString()

            it 'should call res.send(500, {unknown}) if err does not exist', ->
                @controller.failure()

                expect( @res.send ).to.have.been.called.once
                expectArgs( @res.send ).to.have.been 500, 'An unknown error occurred.'

