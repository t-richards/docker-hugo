# Builder image
FROM golang:1.18-alpine as builder

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
	url='https://github.com/gohugoio/hugo/archive/v0.100.0.tar.gz'; \
	sha256='790c4f218e6380f31a0d5c10bacc7e1f7b1533ccba88ef526f764d413325cff1'; \
	\
	wget -O hugo.tar.gz "$url"; \
	echo "$sha256  hugo.tar.gz" | sha256sum -c -; \
	tar xvf hugo.tar.gz; \
	cd hugo-0.100.0; \
	go install -v -ldflags '-s -w' --tags extended

# Runtime image
FROM alpine:3.15

# Versions
ENV HUGO_VERSION 0.100.0

# Add hugo
COPY --from=builder /go/bin/hugo /usr/local/bin/hugo

# 0. Install system deps
# 1. List remaining installed packages
RUN set -eux; \
	apk add --no-cache --update \
		ca-certificates \
		git \
		libc6-compat \
		libstdc++ \
		npm \
		openjdk17-jre-headless \
	; \
	hugo version; \
	java --version; \
	npm version; \
	mkdir -p /site; \
	apk info -vv | sort

WORKDIR /site
ARG VCS_REF
LABEL org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/t-richards/docker-hugo"
