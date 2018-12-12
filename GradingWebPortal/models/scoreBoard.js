const mongoose = require('mongoose');

const scoreBoardSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    teamName: {type: String},
    averageScore : {type: String}
});

module.exports = mongoose.model('ScoreBoard', scoreBoardSchema);