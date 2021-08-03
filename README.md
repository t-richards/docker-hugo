# docker-hugo

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
docker run -v $(pwd):/site ghcr.io/trichards/hugo hugo --gc && vnu --skip-non-html public/
```

## Building this image

```
docker build -t ghcr.io/trichards/hugo .
```

[hugo]: https://github.com/gohugoio/hugo
[vnu]: https://github.com/validator/validator
