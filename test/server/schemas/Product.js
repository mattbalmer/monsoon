var mongoose = require('mongoose-q')();

var ProductSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    price: Number,
    quantity: Number
});

mongoose.model('Product', ProductSchema);