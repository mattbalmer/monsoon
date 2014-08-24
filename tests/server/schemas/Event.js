var mongoose = require('mongoose-q')();

var EventSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    date: String
});

//mongoose.model('Event', EventSchema);
module.exports = EventSchema;