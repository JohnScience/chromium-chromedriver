# chromium-chromedriver

A Docker image that runs Chromium + chromedriver as a service.

## Probably does not work with docker-compose

This image was tested to work as a standalone container. It may not work with `docker-compose` or Docker swarm because of how `chromedriver` is invoked.

The discussion of how to fix the code is available at <https://github.com/ik1ne/webdriver-downloader/issues/59>.

## What might work?

See <https://hub.docker.com/r/spryker/chromedriver>.

But it may be insecure because of how `chromedriver` is invoked there:

```console
chromedriver --port=4444 --whitelisted-ips --allowed-origins=*
```

And `spryker/chromedriver` supports only `amd64` and `arm64` architectures, while this image theoretically supports a wider range of architectures.
