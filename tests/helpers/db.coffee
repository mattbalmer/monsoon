# db.coffee
mongoose = require 'mongoose'

DB =
    connected: null
    Event: null
    Product: null
    connection: null

DB.connect = (done)->
    unless DB.connection
        # Connect to a database which is for test
        mongoose.connect 'mongodb://localhost/monsoon-demo'
        DB.connection = mongoose.connection

        DB.Event = require('./../../server/schemas/Event')(mongoose)
        DB.Product = require('./../../server/schemas/Product')(mongoose)

    done()

DB.drop = (done)->
    if DB.connected
        DB.connection.db.dropDatabase ()->
            console.log 'database has been dropped!'
            done()
    else
        mongoose.connection.on 'connected', ()->
            DB.connected = true
            DB.connection.db.dropDatabase ()->
                console.log 'database has been dropped!'
                done()

# Drop a collection
DB.dropCollection = (collection, done) ->
    DB.connection.db.dropCollection collection, (err)->
        throw err if err
        console.log 'collection '+collection+' has been dropped!'
        done()

module.exports = DB