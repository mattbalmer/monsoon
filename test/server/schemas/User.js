var mongoose = require('mongoose-q')();

var UserSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    email: String
});

mongoose.model('User', UserSchema);