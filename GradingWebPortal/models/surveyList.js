const mongoose = require('mongoose');

const surveyListSchema = new mongoose.Schema({
    _id: mongoose.Schema.Types.ObjectId,
    question1: {type: String},
    question2: {type: String},
    question3: {type: String},
    question4: {type: String},
    question5: {type: String},
    question6: {type: String},
    question7: {type: String},
    question8: {type: String},
});

module.exports = mongoose.model('SurveyList', surveyListSchema);