FROM elixir:alpine AS build

RUN apk add --update nodejs npm

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/

RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets ./assets

RUN npm run --prefix ./assets relay
RUN npm run --prefix ./assets build
RUN mix phx.digest

# compile and build release
COPY lib lib
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release
# RUN ls -lR  /app/_build/prod/rel//
# prepare release image
FROM erlang:alpine AS app

WORKDIR /app
RUN chown -R nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/towns_kings ./

EXPOSE 4000
CMD ["bin/towns_kings", "start"]