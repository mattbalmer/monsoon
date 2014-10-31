supertest = require 'supertest'
db = require './helpers/db'
h = require './helpers/common'
{last, status, body, expectDocument} = require './helpers/supertest'

describe 'Custom Controllers', ->

    # ==== Sample Data ====

    server = null
    sampleId = '0123456789abcdefghijklmn'
    id = ''
    doc = {}
    data =
        name: 'Look, an product!'
        date: '4/3/21'

    # ==== Helper Functions ====

    clearCollection = (done)->
        db.Product.collection.remove {}, ()->
            done()

    create = (done)->
        db.Product.create data, (err, _doc)->
            throw new Error('Setup failed to create an Product') if err
            throw new Error('Setup failed to create an Product') unless h.aIncludesB(_doc, data)

            doc = h.docObj(_doc)
            id = doc._id

            done(_doc)

    # ==== Before ====

    before (done)->
        server = supertest 'http://localhost:3000/api/products'
        db.connect()
        db.drop(done)

    beforeEach (done)->
        id = sampleId
        doc = {}
        clearCollection(done)

    # ==== Tests ====

    describe 'GET /status', ->
        it 'should return json', (done)->
            server.get '/status'
            .expect status 200
            .expect body { status: 'online' }
            .end done