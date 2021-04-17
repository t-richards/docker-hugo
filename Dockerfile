# Builder image
FROM golang:1.16-alpine as builder

RUN set -eux; \
	apk add --no-cache --update \
		alpine-sdk \
		git \
	; \
	\
	url='https://github.com/gohugoio/hugo/archive/v0.82.0.tar.gz'; \
	sha256='f156c31034f013b11ff19aec09ab4d47fd8689befaa6f58222b48ed970722b4b'; \
	\
	wget -O hugo.tar.gz "$url"; \
	echo "$sha256  hugo.tar.gz" | sha256sum -c -; \
	tar xvf hugo.tar.gz; \
	cd hugo-0.82.0; \
	go install -v -ldflags '-s -w' --tags extended

# Runtime image
FROM alpine:3.13

# Versions
ENV HUGO_VERSION 0.82.0
ENV VNU_VERSION 20.3.16

# Add hugo, wrapper script for v.Nu
COPY --from=builder /go/bin/hugo /usr/local/bin/hugo
COPY vnu /usr/local/bin/vnu

# 0. Install system deps
# 1. Download and install v.Nu
# 2. Show app versions
# 3. List remaining installed packages
RUN set -eux; \
	apk add --no-cache --update \
		ca-certificates \
		git \
		libc6-compat \
		libstdc++ \
		openjdk8-jre-base \
	; \
	\
	url='https://github.com/validator/validator/releases/download/20.3.16/vnu.jar_20.3.16.zip'; \
	sha256='1d5b3f0ded0a1e6f9d26a0be5c051a9590a11c8aab2e12d208120a3063e7bdcd'; \
	\
	wget -O validator.zip "$url"; \
	echo "$sha256  validator.zip" | sha256sum -c -; \
	unzip -j validator.zip dist/vnu.jar -d /usr/local/lib; \
	rm -f validator.zip; \
	\
	vnu --version; \
	hugo version; \
	mkdir -p /site; \
	apk info -vv | sort

WORKDIR /site
ARG VCS_REF
LABEL org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/t-richards/docker-hugo"
