const jwt = require('jsonwebtoken');
const redis = require('./redis')
const config = require('./config')

module.exports = (req, res, next) => {
    let player = redis.hget('tokens', req.params.token)

    res.send(jwt.sign({player}, config.secret, {algorithm: 'HS256'}))
}