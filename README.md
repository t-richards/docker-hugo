# docker-hugo

A docker image with [Hugo][hugo], the static site generator, and NPM for asset compilation.

## Intended usage

```bash
# Build site
hugo --gc --minify
```

## Example run

```bash
docker run -v $(pwd):/site ghcr.io/t-richards/hugo hugo --gc public/
```

## Building this image

```
docker build -t ghcr.io/t-richards/hugo .
```

[hugo]: https://github.com/gohugoio/hugo
