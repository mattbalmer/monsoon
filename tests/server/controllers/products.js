var mongoose = require('mongoose-q')(),
    monsoon = require('../../../'),
    Product = mongoose.model('Product'),
    products = module.exports = monsoon.router(Product);

products.get('/status', function(req, res) {
    res.json({
        status: 'online'
    })
});