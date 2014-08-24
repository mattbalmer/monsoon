# db.coffee
mongoose = require 'mongoose'

# Connect to a database which is for test
mongoose.connect 'mongodb://localhost/monsoon-demo'
connection = mongoose.connection

EventSchema = require './server/schemas/Event'

console.log 'eventschema', EventSchema

# Register models
mongoose.model 'Event', EventSchema
mongoose.model 'Product', require './server/schemas/Product'
mongoose.model 'User', require './server/schemas/User'

# Assign models
Event = mongoose.model 'Event'
Product = mongoose.model 'Product'
User = mongoose.model 'User'

drop = (done)->
    mongoose.connection.on 'connected', ()->
        connection.db.dropDatabase ()->
            console.log 'database has been dropped!', arguments
            done()

# Drop a collection
dropCollection = (collection, done) ->
    connection.db.dropCollection collection, ()->
        console.log 'collection '+collection+' has been dropped!'
        done()

module.exports =
    drop: drop
    dropCollection: dropCollection
    Event: Event
    Product: Product
    User: User