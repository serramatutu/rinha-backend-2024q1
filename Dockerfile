FROM alpine:3.19 AS build

# A flag --mount="type=cache" pode ser usada para reusar artefatos de outras builds.
# Nesse caso, estamos reutilizando a pasta /etc/apk/cache, que contém um cache dos pacotes do Alpine Linux.
# Veja:
# - Docs da flag --mount: https://docs.docker.com/build/cache/#use-the-dedicated-run-cache
# - Cache do APK: https://wiki.alpinelinux.org/wiki/Local_APK_cache
RUN --mount="type=cache,target=/etc/apk/cache" \
    apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing zig

WORKDIR /app

COPY build.zig build.zig.zon ./
COPY src/ src/
# Novamente reusando a flag --mount, dessa vez para reusar o build cache do zig
# e evitar 20 segundos de build toda vez
RUN --mount="type=cache,target=/app/zig-cache" \
    zig build -Doptimize=Debug


# Multi-stage builds

FROM alpine:3.19 AS prod

COPY --from=build /app/zig-out/bin /app
ENTRYPOINT [ "/app/rinha-backend" ]
