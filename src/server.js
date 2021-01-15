const express = require('express');
const { graphqlHTTP } = require('express-graphql');
const { buildSchema } = require('graphql');
const fs = require('fs')
const url = require('url')
const ejwt = require('express-jwt');
const cors = require('cors');

const config = require('../config.json');


// GraphQL schema
let schema = buildSchema(fs.readFileSync('schema.v1.graphql').toString('utf8'));

// Create an express server and a GraphQL endpoint
let app = express();
app.use(cors())
app.options('*', cors());
app.use(ejwt({
    secret: config.secret,
    algorithms: ['HS256'],
    getToken: (req) => req.headers.auth
    })
    .unless((s) => url.parse(s.originalUrl).pathname.startsWith('/t')));
app.use('/api', graphqlHTTP({
    schema: schema,
    rootValue: require('./root'),
    graphiql: !config.production
}));

app.use(function (err, req, res, next) {
    if (err.name === 'UnauthorizedError') {
        res.status(401).send(JSON.stringify({error: "No token"}));
    }
});

app.use('/t/:token', require('./token'))

const http = config.production ? require('https') : require('http');
let server;

if (config.production) {

    const credentials = {
        key: fs.readFileSync(config.key, 'utf8'),
        cert: fs.readFileSync(config.cert, 'utf8')
    };

    server = http.createServer(credentials, app)
} else {
    server = http.createServer(app)
}

server.listen(config.port,
    () => console.log(`Express GraphQL Server Now Running On localhost:${config.port}/api`)
);