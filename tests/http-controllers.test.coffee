{expect} = require 'chai'
supertest = require 'supertest'
db = require './helper-db'
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
                .expect 201, (err, res)->
                    result = JSON.parse res.body

                    db.Event.findById result._id, (err, doc)->
                        expect doc
                            .to.equal result

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