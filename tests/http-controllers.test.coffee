{expect} = require 'chai'
supertest = require 'supertest'
db = require './helper-db'
mockErrors = require './mock-db-errors'
{expectDoc, docObj, includes} = require './helpers'
server = supertest 'http://localhost:3000/api/events'

describe 'http-controllers', ->

    before (done)->
        db.drop(done)

    describe 'clean', ->
        id = '0123456789abcdefghijklmn'

        it 'GET /', (done)->
            server.get '/'
                .expect 200
                .expect '[]'
                ,done

        it 'POST /', (done)->
            event =
                name: 'An Event'
                date: '1/2/34'

            server.post '/'
                .send event
                .expect 201
                ,(err, res)->
                    expect(res.status).to.equal 201
                    result = res.body

                    db.Event.findById result._id, (err, doc)->
                        expectDoc(doc).toEqual result

                        done()

        it 'GET /:id', (done)->
            server.get '/'+id
                .expect 404
                .expect ''
                ,done

        it 'DELETE /:id', (done)->
            server.delete '/'+id
                .expect 404
                .expect ''
                ,done

        it 'PUT /:id', (done)->
            server.put '/'+id
                .expect 404
                .expect ''
                ,done

        it 'PATCH /:id', (done)->
            server.patch '/'+id
                .expect 404
                .expect ''
                ,done

    describe 'with starting data', ->
        id = ''
        doc = {}
        data =
            name: 'Look, an event!'
            date: '4/3/21'

        create = (done)->
            db.Event.create data, (err, _doc)->
                throw new Error('Setup failed to create an Event') if err

                doc = docObj(_doc)
                id = doc._id

                expect(doc).to.include data
                done()

        beforeEach (done)->
            db.Event.collection.remove {}, ()->
                create(done)

        it 'GET /', (done)->
            server.get '/'
                .expect 200
                .expect [doc]
                ,done

        it 'POST / (conflict)', (done)->
            event =
                _id: id
                name: 'An Event'
                date: '1/2/34'

            server.post '/'
                .send event
                .expect 409
                .expect {}
                ,done

        it 'GET /:id', (done)->
            server.get '/'+id
                .expect 200
                .expect doc
                ,done

        it 'DELETE /:id', (done)->
            server.delete '/'+id
                .expect 204
                ,(err, res)->
                    expect( res.status ).to.equal 204
                    expect( includes(res.body, {}) ).to.equal true

                    db.Event.findById doc._id, (err, doc)->
                        expectDoc(doc).toEqual {}

                        done()

        it 'PUT /:id', (done)->
            newData =
                name: 'A new event'
                date: '9/8/76'

            server.put '/'+id
                .send newData
                .expect 200
                ,(err, res)->
                    expect( res.status ).to.equal 200

                    expect( includes(newData, res.body) ).to.equal true

                    db.Event.findById res.body._id, (err, doc)->
                        expect( includes(newData, doc) ).to.equal true

                        done()

        it 'PATCH /:id', (done)->
            newData =
                name: 'A new event'

            server.patch '/'+id
                .send newData
                .expect 200
                ,(err, res)->
                    expected =
                        name: newData.name
                        date: data.date

                    expect( res.status ).to.equal 200

                    expect( includes(expected, res.body) ).to.equal true

                    db.Event.findById res.body._id, (err, doc)->
                        expect( includes(expected, doc) ).to.equal true

                        done()