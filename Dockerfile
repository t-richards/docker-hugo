# Builder image
FROM golang:1.17.4-alpine as builder

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
	url='https://github.com/gohugoio/hugo/archive/v0.89.4.tar.gz'; \
	sha256='9d4f61788f8d886913a1be15b3eae04fad04a4e243bd7f65c5e7367bd617856d'; \
	\
	wget -O hugo.tar.gz "$url"; \
	echo "$sha256  hugo.tar.gz" | sha256sum -c -; \
	tar xvf hugo.tar.gz; \
	cd hugo-0.89.4; \
	go install -v -ldflags '-s -w' --tags extended

# Runtime image
FROM alpine:3.14.3

# Versions
ENV HUGO_VERSION 0.89.4
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
