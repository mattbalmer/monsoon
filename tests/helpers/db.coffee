# db.coffee
mongoose = require 'mongoose'

DB =
    connected: undefined
    Event: {}
    Product: {}
    connection: {}

connect = ()->
    unless DB.connected
        # Connect to a database which is for test
        mongoose.connect 'mongodb://localhost/monsoon-demo'
        DB.connection = mongoose.connection

        require('./../../server/schemas/Event')(mongoose)
        require('./../../server/schemas/Product')(mongoose)

    DB.connected = true

    # Assign models
    DB.Event = mongoose.model('Event')
    DB.Product = mongoose.model('Product')

drop = (done)->
    mongoose.connection.on 'connected', ()->
        DB.connection.db.dropDatabase ()->
            console.log 'database has been dropped!'
            done()

# Drop a collection
dropCollection = (collection, done) ->
    DB.connection.db.dropCollection collection, (err)->
        throw err if err
        console.log 'collection '+collection+' has been dropped!'
        done()

module.exports =
    connect: connect
    drop: drop
    dropCollection: dropCollection
    Event: DB.Event
    Product: DB.Product