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

# Tiny HTTP server for Render
RUN printf '%s\n' \
'#!/bin/sh' \
'set -e' \
'' \
'PORT="${PORT:-3000}"' \
'' \
'# Start a tiny HTTP server for Render health checks' \
'python3 -m http.server "$PORT" --bind 0.0.0.0 >/dev/null 2>&1 &' \
'' \
'# Start wireproxy' \
'exec /usr/bin/wireproxy --config /etc/wireproxy/config' \
> /app/start.sh && chmod +x /app/start.sh

VOLUME ["/etc/wireproxy"]

EXPOSE 3000

ENTRYPOINT ["/app/start.sh"]

LABEL org.opencontainers.image.title="wireproxy"
LABEL org.opencontainers.image.description="Wireguard client that exposes itself as a socks5 proxy"
LABEL org.opencontainers.image.licenses="ISC"
