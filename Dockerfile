# Build tools
FROM oven/bun:1.3.14-alpine AS bun

# Runtime image
FROM alpine:3.24

COPY --from=bun /usr/local/bin/bun /usr/local/bin/

RUN set -eux; \
# 0. Install system packages
	apk add --no-cache --update \
		ca-certificates \
		git \
	; \
# 1. Install Hugo from the edge branch
	apk add --no-cache --update \
		--repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
		hugo \
	; \
# 3. Show versions
	hugo version; \
	bun --version; \
	mkdir -p /site; \
# 4. List remaining installed packages
	apk info -vv | sort

WORKDIR /site
