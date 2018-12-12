const mongoose = require('mongoose');

const evaluationSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    teamName: {type: String},
    evaluatorName : {type: String},
    totalScore : {type: String}
});

module.exports = mongoose.model('Evaluations', evaluationSchema);