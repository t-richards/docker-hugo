# Build image
FROM golang:1.13-alpine as builder

ENV HUGO_VERSION 0.62.1

RUN apk add --update --no-cache alpine-sdk git \
 && wget -O /tmp/hugo.tar.gz \
    https://github.com/gohugoio/hugo/archive/v${HUGO_VERSION}.tar.gz \
 && tar xvf /tmp/hugo.tar.gz \
 && cd hugo-${HUGO_VERSION} \
 && go install -v -ldflags '-s -w' --tags extended

# Runtime image
FROM alpine:3.11

# Versions
ENV HUGO_VERSION 0.62.1
ENV VNU_VERSION 18.11.5

# Add hugo, wrapper script for v.Nu
COPY --from=builder /go/bin/hugo /usr/local/bin/hugo
COPY vnu /usr/local/bin/vnu

# 0. Install system deps
# 1. Download and install v.Nu
# 2. Show app versions
# 3. List remaining installed packages
RUN apk add --update --no-cache ca-certificates libc6-compat libstdc++ openjdk8-jre-base \
 && wget -O /tmp/validator.zip \
    https://github.com/validator/validator/releases/download/${VNU_VERSION}/vnu.jar_${VNU_VERSION}.zip \
 && unzip /tmp/validator.zip \
 && mv dist/vnu.jar /usr/local/lib/vnu.jar \
 && rm -rf dist /tmp/validator.zip \
 && vnu --version \
 && hugo version \
 && mkdir -p /site \
 && apk info -vv | sort

WORKDIR /site
ARG VCS_REF
LABEL org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/t-richards/docker-hugo"
