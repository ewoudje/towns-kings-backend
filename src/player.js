const redis = require('./redis')

module.exports = ({player}, req) => ({
    id: player,
    name: async () => await redis.hget("player:" + player, "name")
})