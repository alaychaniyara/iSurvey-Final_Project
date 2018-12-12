const mongoose = require('mongoose');

const teamSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    teamName: {type: String},
    qrCode : {type: String},
    qrImage : {type: String}
});

module.exports = mongoose.model('Team', teamSchema);