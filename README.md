# docker-hugo

[![Docker Automated build](https://img.shields.io/docker/automated/trichards/hugo.svg)](https://hub.docker.com/r/trichards/hugo/)
[![Docker Image Size](https://images.microbadger.com/badges/image/trichards/hugo.svg)](https://microbadger.com/images/trichards/hugo)

A docker image with [Hugo][hugo] and the [The Nu Html Checker][vnu].

## Intended usage

```bash
# Build site
hugo --gc

# Lint generated html
vnu --skip-non-html public/
```

## Example run

```bash
docker run -v $(pwd):/site trichards/hugo hugo --gc && vnu --skip-non-html public/
```

## Building this image

```
docker build -t trichards/hugo .
```

[hugo]: https://github.com/gohugoio/hugo
[vnu]: https://github.com/validator/validator
