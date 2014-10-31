var defaultMongoose = require('mongoose-q')();

module.exports = function(mongoose) {
    mongoose = mongoose || defaultMongoose;

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
    return mongoose.model('Product');
};