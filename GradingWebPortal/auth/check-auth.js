const jwt = require('jsonwebtoken');
const private_secret_key = "JWTAuthValue";


module.exports = (req,res,next) => {
    try{
        const token = req.headers.authorization.split(" ")[1];
        console.log(token);
        const decoded = jwt.verify(token, private_secret_key);
        console.log('decoded', decoded);
        req.userData = decoded;
        next();
    }catch(err){
        return res.status(400).json({
            message: 'failed',
            error:err
        });
    }
};