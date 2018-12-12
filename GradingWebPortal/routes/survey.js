const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Survey = require('../models/surveyList');

let Q1 = "";
let Q2 = "";
let Q3 = "";
let Q4 = "";
let Q5 = "";
let Q6 = "";
let Q7 = "";
let Q8 = "";

router.get('/showSurveyPage', function(req,res) {
   console.log("Showing a new survey with the total number of question:");
   res.render('survey',{title:'Surveys'});
});

router.get('/previewCurrentSurvey', function(req,res) {
    console.log("Showing a new survey with the total number of question:");
    res.render('viewSurvey',{title:'Current Evaluator Survey'});
});

router.post('/deleteSurvey' , function(req,res) {
    console.log("Deleting the survey");
    Survey.remove().exec();
    res.render('deleteSurvey',{title:'No Surveys', message:'Survey Deleted!!!'})
});

router.get('/fetchCurrentSurvey', function (req,res) {
   console.log("Viewing the latest survey questions");
   Survey.find({},{_id: 0 ,question1:1 , question2: 1, question4: 1,question5: 1,
       question6: 1, question7: 1,question8: 1}).exec().then(data => {
           console.log(data.length);
           if (data.length >0){
               data.map(doc => {
                  Q1 = doc.question1;
                  Q2 = doc.question2;
                  Q3 = doc.question3;
                  Q4 = doc.question4;
                  Q5 = doc.question5;
                  Q6 = doc.question6;
                  Q7 = doc.question7;
                  Q8 = doc.question8;
               });
               res.render('viewSurvey',{title:'Current Evaluator Survey',
                   q1:Q1,q2:Q2,q3:Q3,q4:Q4,q5:Q5,q6:Q6,q7:Q7,q8:Q8});
           }else{
               res.render('deleteSurvey',{title:'No surveys to display',message:'No surveys to display'});
           }

   }).catch(err => {
      console.log("Error loading the current survey: ", err);
   });
});

router.post('/addSurvey', function(req,res){
   console.log('Adding new survey request', req.body);
   Survey.find().exec()
       .then(survey => {
            if(survey.length > 0){
               Survey.remove().exec();
            }
           const newSurvey = new Survey({
               _id: new mongoose.Types.ObjectId(),
               question1: req.body.ques1,
               question2: req.body.ques2,
               question3: req.body.ques3,
               question4: req.body.ques4,
               question5: req.body.ques5,
               question6: req.body.ques6,
               question7: req.body.ques7,
               question8: req.body.ques8
           });
           newSurvey.save().then(result => {
               res.header('Cache-Control', 'no-cache, private, no-store, must-revalidate, max-stale=0, post-check=0, pre-check=0');
               res.render('dashboard',{title:'Dashboard'});
           })
       }).catch(err=> {
            res.status(500).json({
                message : "Error adding the survey",
                error: err
            });
   });
});


module.exports = router;