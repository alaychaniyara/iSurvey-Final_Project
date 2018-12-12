const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const ScoreBoard = require('../models/scoreBoard');


router.get('/showScoreBoard', function(req,res) {
   console.log("Opening score board ");
   res.render('scoreBoard',{title:'Score Board'});
});

router.get('/fetchScores', function(req,res) {
    ScoreBoard.find({},{_id: 0 ,teamName: 1 , averageScore: 1}).sort( { averageScore: -1 } ).exec().then(data =>{
        console.log('Score Board : ', data);
        res.status(200).json({"data" : data})
    }).catch(err=>{
        res.status(500).json({
            message :'Error reading scoreboards',
            error: err
        })
    })
});


module.exports = router;
