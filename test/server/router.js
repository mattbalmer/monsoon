var routes = module.exports = require('express').Router()
    , monsoon = require('../../')
    , mongoose = require('mongoose-q')()
    , Event = mongoose.model('Event');

var events = monsoon.router(Event).export();

routes.use( '/api/events', events );