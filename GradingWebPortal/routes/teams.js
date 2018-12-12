const createError = require('http-errors');
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const Team = require('../models/team');
const checkAuth = require('../auth/check-auth');
const private_secret_key = "JWTAuthValue";
const qrCode = require('qrcode');
const fs = require('fs');
const AWS = require('aws-sdk');

router.get('/showTeams', function (req,res) {
    console.log("Displaying the teams page");
    res.render('teams',{title:'teams'});
});

router.get('/fetchTeams',   function(req,res) {
    console.log("fetching team details.... token value is", req.body.token);
    Team.find({},{_id: 0 ,teamName:1 , qrCode: 1}).exec()
        .then( data => {
            console.log({data});
            res.status(200).json({"data":data});
        }).catch( err => {
        res.status(500).json({err});
    });
});

router.post('/addTeam',  function(req, res) {
    console.log("Create a new team", req.body);
    Team.find({teamName : req.body.teamName})
        .exec()
        .then(team => {
            if(team.length >= 1) {
                res.status(409);
                res.statusMessage = "Error creating user";
                res.header('Cache-Control', 'no-cache, private, no-store, must-revalidate, max-stale=0, post-check=0, pre-check=0');
                res.render('error',{title:'Error'});
            }else {
                let generatedCode = jwt.sign({
                    teamName : req.body.teamName
                },private_secret_key,{expiresIn : "15 days"});
                console.log("The generated QR Code ," , generatedCode);
                qrCode.toFile('qrcodes/teams/qrImg.png', generatedCode);
                /*fs.readFile('qrcodes/teams/qrImg.png' , function(err,data){
                   if (err) throw err;
                   let s3Bucket = new AWS.S3({params:{Bucket:'teamCodes'}});

                });*/
                const newTeam = new Team({
                    _id: new mongoose.Types.ObjectId(),
                    teamName: req.body.teamName,
                    qrCode: generatedCode
                });
                newTeam.save().then(result => {
                    res.header('Cache-Control', 'no-cache, private, no-store, must-revalidate, max-stale=0, post-check=0, pre-check=0');
                    res.render('dashboard',{title:'Dashboard'});
                }).catch(err => {
                    res.render('error',{title:err});
                });
            }
        }).catch(err => {
        res.status(500).json({
            message : "Error encountered",
            error: err
        })
    });
});

module.exports = router;