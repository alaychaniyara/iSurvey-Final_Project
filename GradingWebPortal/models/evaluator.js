const mongoose = require('mongoose');

const evaluatorSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    evaluatorName: {type: String},
    qrCode : {type: String}
});

module.exports = mongoose.model('Evaluator', evaluatorSchema);