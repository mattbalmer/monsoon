var mongoose = require('mongoose-q')();

var ProductSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    price: Number,
    quantity: Number,

    _id: {
        type: mongoose.Schema.ObjectId,
        default: function() {
            var ObjectId = mongoose.Types.ObjectId;
            return new ObjectId();
        }
    }
});

mongoose.model('Product', ProductSchema);