const AWS = require('aws-sdk');
const multer = require('multer');
const multerS3 = require('multer-s3');
const BUCKET_NAME = "teamcodes";

let awsConfig = {
    "region" : "us-east-2",
    "endPoint" : "http://dynamodb.us-east-1.amazonaws.com",
    "accessKeyId" : "",
    "secretAccessKey" : ""
};
AWS.config.update(awsConfig);

const s3 = new AWS.S3();

const upload = multer({
    storage: multerS3({
        s3,
        bucket: BUCKET_NAME,
        acl: 'public-read',
        metadata: function (req, file, cb) {
            console.log('Inside file-upload');
            cb(null, {fieldName: 'QR_CODE_IMAGE'});
        },
        key: function (req, file, cb) {
            cb(null, file.originalname)
        }
    })
});


module.exports = upload;
