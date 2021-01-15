const redis = require('./redis')

module.exports = (input, req) => {
    if (input.demo) {
        let result = {id: input.demo};

        result.name = async () => await redis.hget(`demo:${input.demo}`, 'name')

        return result;
    }
}