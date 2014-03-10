var app = module.exports = require('express')(), monsoon = require('monsoon');

// Resources
app.use( '/products', monsoon.app(require('./api/products')) );
app.use( '/events', monsoon.app('Event') );
app.use( '/users', monsoon.app('User') );