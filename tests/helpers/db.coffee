# db.coffee
mongoose = require 'mongoose'

# Connect to a database which is for test
mongoose.connect 'mongodb://localhost/monsoon-demo'
connection = mongoose.connection

# Assign models
Event = require('./../../server/schemas/Event')(mongoose)

drop = (done)->
    mongoose.connection.on 'connected', ()->
        connection.db.dropDatabase ()->
            console.log 'database has been dropped!'
            done()

# Drop a collection
dropCollection = (collection, done) ->
    connection.db.dropCollection collection, (err)->
        throw err if err
        console.log 'collection '+collection+' has been dropped!'
        done()

module.exports =
    drop: drop
    dropCollection: dropCollection
    Event: Event