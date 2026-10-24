# erugo-php

Erugo 0.2.15 (self-hosted file sharing) with a patched PHP runtime: **PHP 8.3 ≥ 8.3.36**, which contains the fix for PHP2Shell
(CVE-2026-109618/109619, multipart `POST` parsing).

The upstream image is built on Alpine 3.19 (end-of-life), where php83 stays at 8.3.14. This image mirrors upstream's final build stage on Alpine 3.22 and copies the application, vendor/ and built assets from the upstream image.

The application itself is taken unchanged from the pinned upstream image
(`wardy784/erugo:latest`, digest in the `Dockerfile`); only the PHP runtime underneath is replaced. It is a
drop-in replacement: same ports, volumes, entrypoint and environment variables as upstream.
See [https://github.com/ErugoOSS/Erugo](https://github.com/ErugoOSS/Erugo) for usage.

## Image

```
ghcr.io/torreirow/erugo-phpatest
ghcr.io/torreirow/erugo-php:<upstream-version>
ghcr.io/torreirow/erugo-php:<upstream-version>-<commit>
```

Pin by digest in production.

## Build

```sh
docker build -t erugo-php .
```

The build fails if the installed PHP is older than `PHP_MIN` (build argument, default
`8.3.36`).

## CI

`.github/workflows/build.yml` builds the image, smoke-tests it (HTTP endpoints, PHP version
≥ `PHP_MIN`) and pushes to ghcr.io on `main`. A weekly scheduled run rebuilds without cache so
new PHP patch releases from the distribution packages end up in the image.

## Upgrading upstream

1. Update the `UPSTREAM` digest in the `Dockerfile` and the version in `UPSTREAM_VERSION`.
2. Push; CI builds, tests and publishes.

Retire this repository once upstream ships an image with PHP ≥ 8.3.36 (or another patched
branch).

## License

MIT for the files in this repository. Erugo 0.2.15 (self-hosted file sharing) itself is licensed by its authors; see upstream.
