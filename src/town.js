const redis = require('./redis')

module.exports = async ({town}, req) => ({
    id: town,
    name: async () => await redis.hget(`town:${town}`, 'name'),
    members: async () => (await redis.smembers(`town:${town}:members`))
        .map((s) => require('./player')({player: s})),
    demos: async () =>
        (await redis.hvals(`town:${town}:demos`))
            .map((s) => require('./demographic')({demo: s}))
})