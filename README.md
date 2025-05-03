# docker-hugo

A multi-arch docker image with [Hugo][hugo], the static site generator, and NPM for asset compilation.

## Available architectures

- `linux/amd64`
- `linux/arm64`

## Example usage

```bash
docker run -v $(pwd):/site ghcr.io/t-richards/hugo hugo --gc --minify
```

## Building this image

```
docker build -t ghcr.io/t-richards/hugo .
```

[hugo]: https://github.com/gohugoio/hugo
