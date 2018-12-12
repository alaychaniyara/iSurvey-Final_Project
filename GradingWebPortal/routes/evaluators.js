const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const Evaluator = require('../models/evaluator');
const Team = require('../models/team');
const Survey = require('../models/surveyList');
const Evaluations = require('../models/evaluations');
const ScoreBoard = require('../models/scoreBoard');
const checkAuth = require('../auth/check-auth');
const private_secret_key = "JWTAuthValue";
const qrCode = require('qrcode');
let scoreCount = 0;
let numbrOfScores = 0;
let avgScore = [];
let teamList = [];

router.get('/showEval', function(req,res) {
   console.log("Show the evaluators screen");
    res.render('evaluators',{title:'Evaluators'});
});

router.get('/fetchEvaluators', function(req,res){
   console.log("inside get of evaluators");
    Evaluator.find({},{_id: 0 ,evaluatorName:1 , qrCode: 1}).exec()
        .then( data => {
            console.log('Evaluator info : ' , data);
            res.status(200).json({data});
        }).catch( err => {
        res.status(500).json({err});
    });
});

router.post('/', function(req,res){
   console.log("inside post of evaluators");
    Evaluator.find({evaluatorName : req.body.evaluatorName})
        .exec()
        .then(team => {
            if(team.length >= 1) {
                res.status(409);
                res.statusMessage = "Error creating user";
                res.header('Cache-Control', 'no-cache, private, no-store, must-revalidate, max-stale=0, post-check=0, pre-check=0');
                res.render('error',{title:'Error'});
            }else {
                let generatedCode = jwt.sign({
                    evaluatorName : req.body.evaluatorName
                },private_secret_key,{expiresIn : "15 days"});
                console.log("The generated QR Code ," , generatedCode);
                qrCode.toFile('qrcodes/evaluators/eval1.png', generatedCode).catch(err => {
                    console.log(err);
                });
                const newEvaluator = new Evaluator({
                    _id: new mongoose.Types.ObjectId(),
                    evaluatorName: req.body.evaluatorName,
                    qrCode: generatedCode
                });
                newEvaluator.save().then(result => {
                    res.header('Cache-Control', 'no-cache, private, no-store, must-revalidate, max-stale=0, post-check=0, pre-check=0');
                    res.render('dashboard',{title:'Dashboard'});
                }).catch(err => {
                    res.status(500).json({
                        message : "Error adding new evaluator",
                        error: err
                    })
                });
            }
        }).catch(err => {
        res.status(500).json({
            message : "Error encountered",
            error: err
        })
    });
});

//API calls for mobile requests

router.post('/authenticateUser', function(req,res){
    console.log('Authentication evaluator' , req.body.scannedCode);
    Evaluator.find({qrCode: req.body.scannedCode}).exec()
        .then( result=> {
            if(result.length > 0){
                console.log('Evaluator Found ', result);
                res.status(200).json({
                    result
                })
            }else{
                res.status(201).json({
                    message : 'Evaluator Not Found',
                    result : result
                });
            }
        }).catch(err => {
            res.status(500).json({
            message : 'Error',
            error : err
        });
});
});

router.get('/teamsList', checkAuth, function (req,res) {
    console.log('Retrieving the list of teams ');
    Team.find().exec()
        .then( data => {
            console.log({data});
            res.status(200).json({
                message : 'Success',
                data : data
            });
        }).catch( err => {
        res.status(500).json({err});
    });
});

router.post('/authenticateTeam', checkAuth, function(req,res){
    console.log('Authentication evaluator' , req.body.scannedCode);
    Team.find({qrCode: req.body.scannedCode}).exec()
        .then( result=> {
            if(result.length > 0){
                console.log('Team Found ', result);
                res.status(200).json({
                    message : 'Team Found',
                    result : result
                })
            }else{
                res.status(201).json({
                    message : 'Team Not Found',
                    result : result
                });
            }
        }).catch(err => {
        res.status(500).json({
            message : 'Error',
            error : err
        });
    });

});

router.get('/displaySurvey', checkAuth, function(req,res) {
    console.log('Displaying the survey');
    Survey.find().exec().then(data => {
        console.log(data.length);
        res.status(200).json({
           message : 'Success',
           data : data
        });
    }).catch(err => {
        res.status(500).json({
           message : 'Error',
           error : err
        });
    });
});

router.post('/submitSurvey', checkAuth, function(req,res) {
    console.log('Submitting evaluator survey ', req.body);//needs evaluator name, team name and final score
    const scoreCard = new Evaluations({
        _id : new mongoose.mongo.ObjectId,
        teamName : req.body.teamName,
        evaluatorName : req.body.evaluatorName,
        totalScore : req.body.totalScore
    });
    scoreCard.save().then(result => {
        finalScoreCard(req,res);
        res.status(200).json({
            message : 'Success',
            result : result
        })
    }).catch(err => {
        res.status(500).json({
            message : 'Error',
            error : err
        })
    });
});

router.get('/viewScoreBoard', checkAuth, function(req,res) {
        ScoreBoard.find().exec().then(data =>{
            res.status(200).json({
                message : 'Success',
                result : data
            })
        }).catch(err=>{
            res.status(500).json({
                message :'Error reading scoreboards',
                error: err
            })
        })
});

function finalScoreCard(req,res){
    ScoreBoard.find().exec().then(data => {
        if (data.length > 0) {
            ScoreBoard.remove().exec();
        }
    }).catch(err => {
        res.status(500).json({
            message : 'Error updating score board',
            error : err
        })
    });
    Team.find().exec()
        .then(result => {
            result.map(doc => {
                Evaluations.find({teamName: doc.teamName}).exec()
                    .then(data => {
                        console.log('Found evaluations for team : ', data);
                        if (data.length > 1) {
                            teamList.push(doc.teamName);
                            numbrOfScores = data.length;
                            data.map(scores => {
                                scoreCount = scoreCount + Number(scores.totalScore);
                            });
                        }else {
                            scoreCount = 0;
                            numbrOfScores = 0;
                        }
                        const scoreBoard = new ScoreBoard({
                            _id : mongoose.Types.ObjectId(),
                            teamName : doc.teamName,
                            averageScore: String(scoreCount/numbrOfScores)
                        });
                        scoreBoard.save().then(result => {
                            console.log('Score Board updated', result);
                        }).catch(err => {
                            console.log('Error saving scores', err);
                        });
                        scoreCount = 0;
                        numbrOfScores = 0;
                    }).catch(err => {
                    console.log('Error calculating average score', err);
                });
            });
        });
}


module.exports = router;