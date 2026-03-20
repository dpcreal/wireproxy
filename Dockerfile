# Build wireproxy
FROM docker.io/golang:1.26 AS build

WORKDIR /usr/src/wireproxy
COPY . .

RUN make

# Runtime image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/src/wireproxy/wireproxy /usr/bin/wireproxy

WORKDIR /app

RUN printf '%s\n' \
'#!/bin/sh' \
'set -e' \
'PORT="${PORT:-10000}"' \
'python3 -m http.server "$PORT" --bind 0.0.0.0 >/dev/null 2>&1 &' \
'exec /usr/bin/wireproxy --config /etc/secrets/config' \
> /app/start.sh && chmod +x /app/start.sh

EXPOSE 10000

ENTRYPOINT ["/app/start.sh"]
