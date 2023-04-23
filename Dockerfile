# Builder image
FROM golang:1.20-alpine as builder

ENV CFLAGS="-O2 -pipe -fno-plt -fexceptions \
        -Wp,-D_FORTIFY_SOURCE=2 \
        -Wformat -Werror=format-security \
        -fstack-clash-protection"
ENV CGO_CPPFLAGS="-D_FORTIFY_SOURCE=2"
ENV CGO_CFLAGS="$CFLAGS"
ENV CGO_CXXFLAGS="$CFLAGS"
ENV CGO_LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"
ENV GOFLAGS="-buildmode=pie -trimpath -mod=readonly -modcacherw"

RUN set -eux; \
	apk add --no-cache --update \
		alpine-sdk \
		git \
	; \
	\
	url='https://github.com/gohugoio/hugo/archive/v0.111.3.tar.gz'; \
	sha256='b6eeb13d9ed2e5d5c6895bae56480bf0fec24a564ad9d17c90ede14a7b240999'; \
	\
	wget -O hugo.tar.gz "$url"; \
	echo "$sha256  hugo.tar.gz" | sha256sum -c -; \
	tar xvf hugo.tar.gz; \
	cd hugo-0.111.3; \
	go install -v -ldflags '-s -w' --tags extended

# Runtime image
FROM alpine:3.17

# Versions
ENV HUGO_VERSION 0.111.3

# Add hugo
COPY --from=builder /go/bin/hugo /usr/local/bin/hugo

# 0. Install system deps
RUN set -eux; \
	apk add --no-cache --update \
		ca-certificates \
		git \
		libc6-compat \
		libstdc++ \
		npm \
		openjdk17-jre-headless \
	; \
# 1. Show versions
	hugo version; \
	java --version; \
	npm version; \
	mkdir -p /site; \
# 2. List remaining installed packages
	apk info -vv | sort

WORKDIR /site
ARG VCS_REF
LABEL org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/t-richards/docker-hugo"
