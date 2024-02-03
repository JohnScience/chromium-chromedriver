# chromium-chromedriver

A Docker image that runs Chromium + chromedriver as a service.

## Probably does not work with docker-compose

The discussion of how to fix the code is available at <https://github.com/ik1ne/webdriver-downloader/issues/59>.

## What works?

See <https://hub.docker.com/r/spryker/chromedriver>.

But it may be insecure because of how `chromedriver` is invoked there:

```console
chromedriver --port=4444 --whitelisted-ips --allowed-origins=*
```
