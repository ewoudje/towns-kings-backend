const Redis = require("ioredis");
const config = require('./config')

module.exports = new Redis({
    host: config.redis.host,
    port: config.redis.port,
    password: config.redis.password
});