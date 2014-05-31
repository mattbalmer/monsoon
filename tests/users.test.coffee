monsoon = require '../index'
supertest = require 'supertest'
mongoose = require 'mongoose'
express = require 'express'
chai = require 'chai'
expect = chai.expect

# === Setup ===
mongoose.connect 'mongodb://localhost/monsoon-test-db'
require './data/User'

app = express()
app.get '/', (req, res)-> res.send 'root'
app.use '/users', monsoon.app 'User'

# === Tests ===
describe '/users', ->
    server = supertest.agent app

    describe 'GET /', ->

        it 'should return 200, []', (done)->
            server.get '/users'
                .expect 200
                .expect '[]', done

#    describe 'GET /:id', ->
#
#        it 'should return 404, null', (done)->
#            server.get '/users/abc123'
#                .expect 200
#                .expect '', done