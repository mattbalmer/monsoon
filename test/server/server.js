var express = require('express')
    , mongoose = require('mongoose-q')();

var app = express(),
    port = 3000;

// === Import Schemas ===
mongoose.connect('mongodb://localhost/monsoon-demo');
require('./schemas/Event.js')();

// === Configure Express ===
app.use( require('body-parser')() );
app.use( require('./router') );

app.listen(port, function() {
    console.log('Application listening on port ' + port)
});