const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    userName: {type: String},
    password: {type: String},
    userRole: {
        type: String,
        enum: ['ADMIN','EVALUATOR']
    }
});

module.exports = mongoose.model('User', userSchema);