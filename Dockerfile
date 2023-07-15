# Runtime image
FROM alpine:3.18

RUN set -eux; \
# 0. Install system packages
	apk add --no-cache --update \
		ca-certificates \
		git \
		libc6-compat \
		libstdc++ \
		npm \
		openjdk17-jre-headless \
	; \
# 1. Install Hugo from the edge branch
	apk add --no-cache --update \
		--repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
		hugo \
	; \
# 3. Show versions
	hugo version; \
	java --version; \
	npm version; \
	mkdir -p /site; \
# 4. List remaining installed packages
	apk info -vv | sort

WORKDIR /site
ARG VCS_REF
LABEL org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/t-richards/docker-hugo"
