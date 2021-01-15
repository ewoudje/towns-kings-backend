const town = require("./town")
const world = require("./world");
const player = require("./player");
const redis = require('./redis')

module.exports = {
    town: town,
    towns: async ({world}) => (await redis.hvals(`world:${world}:towns`))
        .map((s) => require('./town')({town: s})),
    world: world,
    worlds: async () => (await redis.smembers('worlds')).map((s) => world({world: s})),
    player: player,
    players: player
}