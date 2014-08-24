var mongoose = require('mongoose-q')();

var EventSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    date: String,

    _id: {
        type: mongoose.Schema.ObjectId,
        default: function() {
            var ObjectId = mongoose.Types.ObjectId;
            return new ObjectId();
        }
    }
});

mongoose.model('Event', EventSchema);