const createError = require('http-errors');
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const User = require('../models/user');

const private_secret_key = "JWTAuthValue";
const Team = require('../models/team');
const qrCode = require('qrcode');

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send('respond with a resource');
});



router.post('/newUser', function(req, res, next) {
  console.log("Entering admin route.... Creating a new admin login",req.body);
    User.find({ userRole: req.body.userRole})
        .exec()
        .then(user => {
            if(user.length >= 1){
                res.status(409);
                res.statusMessage = "Error creating user";
                res.header('Cache-Control', 'no-cache, private, no-store, must-revalidate, max-stale=0, post-check=0, pre-check=0');
                res.render('error',{title:'Error'});
            }else{
                bcrypt.hash(req.body.password,10,(err,hash) => {
                    if(err) {
                        return res.status(500).json({
                            error: err
                        });
                    }else{
                        const newUser = new User({
                            _id: new mongoose.Types.ObjectId(),
                            userName: req.body.userName,
                            userRole: req.body.userRole,
                            password: hash
                        });
                        newUser.save().then(result => {
                            console.log(result);
                            res.status(201).json({
                                message: ' User Created ',
                                userDetails: {
                                    LoginName : result.userName,
                                    UserRole : result.userRole
                                }
                            })
                        }).catch(err => {
                            console.log('logging the error' , err);
                            res.status(500).json({
                                error:err
                            })
                        });
                    }
                });
            }
        }).catch( err => {
        console.log('Error creating user');
        res.status(500).json({
            message : 'Error creating user',
            error: err
        });
    });
});


router.post('/signIn', function(req,res,next) {
  console.log("Admin signin....", req.body , router.headers);
    User.findOne({userName : req.body.inputEmail}).exec()
        .then( adminUser => {
            console.log('Reading user data' , req.body.inputPassword , '  ', adminUser.password);
            if(adminUser.length < 1){//means no user
                res.status(401).json({
                    message : 'Authentication Failed'
                });
            }
            bcrypt.compare(req.body.inputPassword,adminUser.password, (err,result) =>{
                if(err){
                    res.status(401).json({
                        message : 'Authentication Failed'
                    });
                }
                if(result){//true if comparison is a success
                    const token = jwt.sign({
                        userId : adminUser._id,
                        userName : adminUser.userName,
                        userRole : adminUser.userRole
                    }, private_secret_key,{expiresIn : "15 days"});
                    if (token !== null){
                        let tokenValue = 'BEARER ' + token;
                        req.headers = tokenValue;
                        console.log("Adding to session :", req.headers);
                        res.render('dashboard',{title:'dashboard',token: req.headers});
                    }
                }
            })
        })
        .catch( err => {
            console.log('Error while logging in', err);
            res.status(500).json({
                message : 'Error while logging in',
                error: err
            });
        });
});

module.exports = router;
