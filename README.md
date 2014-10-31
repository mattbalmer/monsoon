# Monsoon
## Extensible REST API Generator

Monsoon allows for easy, extensible CRUD REST API generation using Express & Mongoose.

## Installation

    $ npm install monsoon
    
Monsoon requires both `express` and `mongoose`.

## Quick Start

Using monsoon is easy. Let's assume you have a Schema called `Product`. Your API router might look something like this:

    var express = require('express')
        , monsoon = require('monsoon')
        , mongoose = require('mongoose')
        , Product = mongoose.model('Product')
        , app = module.exports = express();

    // Resources
    app.use( '/products', monsoon.router(Product).export() );

That's it! You now have routes in place for some of the more common REST operations.

## Routes

Currently, Monsoon will generate the following routes & controllers. All various responses and the HTTP codes associated with them have been included.

### METHOD /PATH (example)
**Params:** any URL parameters the method requires  
**Body:** any URL parameters the method requires  
**Returns:** `###` what the controller returns in the response body

### GET /
**Returns:** `200` a JSON array of all documents in the collection  
**Returns:** `500` an error string

### POST /
**Body:** a JSON representation of the document to be created  
**Returns:** `200` a JSON representation of the created document  
**Returns:** `409` an error string  
**Returns:** `500` an error string

### GET /:id
**Params:** a 24-character Mongo ID  
**Returns:** `200` a JSON representation of the document in the collection with the given ID  
**Returns:** `404`  
**Returns:** `500` an error string

### PUT /:id
**Params:** a 24-character Mongo ID  
**Body:** a JSON representation of the updated document  
**Returns:** `200` a JSON representation of the updated document  
**Returns:** `404`  
**Returns:** `500` an error string

### PATCH /:id
**Params:** a 24-character Mongo ID  
**Body:** a JSON object containing the fields & values to update the document with  
**Returns:** `200` a JSON representation of the updated document  
**Returns:** `404`  
**Returns:** `500` an error string

### DELETE /:id
**Params:** a 24-character Mongo ID  
**Returns:** `204`  
**Returns:** `404`  
**Returns:** `500` an error string

## Extending Monsoon Controllers

So you want to add some routes of your own to Monsoon's defaults? No problem, let's just change our API router to look something like this

    var express = require('express')
        , monsoon = require('monsoon')
        , app = module.exports = express();

    // Resources
    app.use( '/products', monsoon.app(require('./products') );

And create a `products.js` file, which will look something like this:

    var monsoon = require('monsoon')
        , controller = module.exports = monsoon.controllers('Product');

    // Custom Controllers
    controllers.get('/status', function(req, res) {
        res.json({
            status: 'online'
        })
    });

And there you have it. Define any routes you wish on the `controllers` object just as you would an Express app (`var app = express()` is common)

## Additional Features

//TODO

## Support

The following are known issues and will be addressed soon

* Multiple controller callbacks/middleware ( `app.get('/path', middlewareFunction, function(req, res) { ... })` )

## Contact & License Info

Author: Matthew Balmer  
Twitter: [@mattbalmer](http://twitter.com/mattbalmer)  
Website: [http://mattbalmer.com](http://mattbalmer.com)  
License: MIT
