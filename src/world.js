const redis = require('./redis')

module.exports = async ({world}, req) => ({
    id: world,
    name: async () => await redis.hget(`world:${world}`, 'name'),
    towns: async () => (await redis.hvals(`world:${world}:towns`))
        .map((s) => require('./town')({town: s}))
})