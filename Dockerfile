# Runtime image
FROM alpine:3.22

RUN set -eux; \
# 0. Install system packages
	apk add --no-cache --update \
		ca-certificates \
		git \
		npm \
	; \
# 1. Install Hugo from the edge branch
	apk add --no-cache --update \
		--repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
		hugo \
	; \
# 3. Show versions
	hugo version; \
	npm version; \
	mkdir -p /site; \
# 4. List remaining installed packages
	apk info -vv | sort

WORKDIR /site
