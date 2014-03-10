var express = require('express')
    , mongoose = require('mongoose');

var app = express()
    , port = 3000;

mongoose.connect('mongodb://localhost/monsoon_demo_ex1');
require('./schemas/Product.js');
require('./schemas/User.js');
require('./schemas/Event.js');

app.use( express.bodyParser() );
app.use( require('./controllers/api.js') );

app.listen(port, function() {
    console.log('Application listening on port ' + port)
});