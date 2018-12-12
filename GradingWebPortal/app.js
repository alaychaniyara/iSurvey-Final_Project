const createError = require('http-errors');
const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const mongoose = require('mongoose');

const indexRouter = require('./routes/index');
const usersRouter = require('./routes/users');
const teamsRouter = require('./routes/teams');
const evaluatorsRouter = require('./routes/evaluators');
const surveyRouter = require('./routes/survey');
const scoresRouter = require('./routes/scoreBoard');

const app = express();

try{
  console.log("trying to connect to mongoose");
    mongoose.connect(
        'mongodb+srv://amad_user:adminPwd@amad-customer-jvsta.mongodb.net/test?retryWrites=true',
        {
            useNewUrlParser:true
        }
    ).then(()=>{
        console.log("Mongo DB Connected");
    }).catch(err => {
        console.log(err);
    });
    mongoose.set('useCreateIndex', true);
}catch(error){
    createError(404);
}


// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', usersRouter);
app.use('/teams', teamsRouter);
app.use('/evaluators', evaluatorsRouter);
app.use('/surveys', surveyRouter);
app.use('/scores', scoresRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
