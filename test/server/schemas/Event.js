var defaultMongoose = require('mongoose-q')();

module.exports = function(mongoose) {
    mongoose = mongoose || defaultMongoose;

    var EventSchema = new mongoose.Schema({
        name: {
            type: String,
            required: true
        },
        date: String
    });

    mongoose.model('Event', EventSchema);
    return mongoose.model('Event');
};