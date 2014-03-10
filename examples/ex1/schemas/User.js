var mongoose = require('mongoose');

var UserSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    email: String,

    _id: {
        type: mongoose.Schema.ObjectId,
        default: function() {
            var ObjectId = mongoose.Types.ObjectId;
            return new ObjectId();
        }
    }
});

mongoose.model('User', UserSchema);