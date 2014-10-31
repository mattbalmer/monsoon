supertest = require 'supertest'
db = require './helpers/db'
h = require './helpers/common'
{last, status, body, expectDocument} = require './helpers/supertest'

describe 'http-controllers', ->
    server = supertest 'http://localhost:3000/api/events'

    # ==== Sample Data ====

    sampleId = '0123456789abcdefghijklmn'
    id = ''
    doc = {}
    data =
        name: 'Look, an event!'
        date: '4/3/21'

    # ==== Helper Functions ====

    clearCollection = (done)->
        db.Event.collection.remove {}, ()->
            done()

    create = (done)->
        db.Event.create data, (err, _doc)->
            throw new Error('Setup failed to create an Event') if err
            throw new Error('Setup failed to create an Event') unless h.aIncludesB(_doc, data)

            doc = h.docObj(_doc)
            id = doc._id

            done(_doc)

    # ==== Before ====

    before (done)->
        db.drop(done)

    beforeEach (done)->
        id = sampleId
        doc = {}
        clearCollection(done)

    # ==== Tests ====

    describe 'GET /', ->
        it 'no entries', (done)->
            server.get '/'
            .expect status 200
            .expect body []
            .end done

        it 'one entry', (done)->
            create ()->
                server.get '/'
                .expect status 200
                .expect body [doc]
                .end done

    describe 'POST /', ->
        it 'successful insertion', (done)->
            event =
                name: 'An Event'
                date: '1/2/34'

            server.post '/'
            .send event
            .expect status 201
            .end last (res)->
                expectDocument res.body._id
                .toEqual res.body
                .end done

        it 'conflict', (done)->
            create ()->
                event =
                    _id: id
                    name: 'An Event'
                    date: '1/2/34'

                server.post '/'
                .send event
                .expect status 409
                .expect body {}
                .end done

        it 'missing required fields', (done)->
            create ()->
                event =
                    date: '1/2/34'

                server.post '/'
                .send event
                .expect status 500
                .expect body {}
                .end done

    describe 'GET /:id', ->
        it 'not found', (done)->
            server.get '/'+id
            .expect status 404
            .expect body ''
            .end done

        it 'found', (done)->
            create ()->
                server.get '/'+id
                .expect status 200
                .expect body doc
                .end done

    describe 'DELETE /:id', ->
        it 'not found', (done)->
            server.delete '/'+id
            .expect status 404
            .expect body ''
            .end done

        it 'deleted', (done)->
            create ()->
                server.delete '/'+id
                .expect status 204
                .expect body {}
                .end last (res)->
                    expectDocument doc._id
                    .toEqual null
                    .end done

    describe 'PUT /:id', ->
        it 'not found', (done)->
            server.put '/'+id
            .expect status 404
            .expect body ''
            .end done

        it 'overwritten', (done)->
            create ()->
                newData =
                    name: 'A new event'
                    date: '9/8/76'

                server.put '/'+id
                .send newData
                .expect status 200
                .expect body.includes newData
                .end last (res)->
                    expectDocument res.body._id
                    .toInclude newData
                    .end done

    describe 'PATCH /:id', ->
        it 'not found', (done)->
            server.patch '/'+id
            .expect status 404
            .expect body ''
            .end done

        it 'updated', (done)->
            create ()->
                newData =
                    name: 'A new event'

                expected =
                    name: newData.name
                    date: data.date

                server.patch '/'+id
                .send newData
                .expect status 200
                .expect body.includes expected
                .end last (res)->
                    expectDocument res.body._id
                    .toInclude newData
                    .end done