# chromium-chromedriver

A Docker image that runs Chromium + chromedriver as a service.

## Why only `amd64` and `arm64`?

Both this image and `spryker/chromedriver` support only `amd64` and `arm64` architectures because these are the only two architectures that `chromedriver` supports.

However, this image relies on [`webdriver-downloader`] for supporting the architectures. As long as `chromedriver` is available for the architecture and [`webdriver-downloader`] supports it, the support of the new architecture should be possible too. For that, the architecture should be added to the build matrix of the `publish-images.yml` workflow.

## Comparison with [`spryker/chromedriver`]

* Safer (see the "Security" section below)
* More flexible (see the "Configuration" section below)
* Slightly larger (250 MB vs 180MB, as of 2024-02-09)

### Configuration

[`spryker/chromedriver`] does not allow to configure `chromedriver` in any way. This image allows to configure `chromedriver` by setting the environment variables with the `-e` option of `docker run`.

#### Environment variables

* `PORT` - the port to listen on (default: `9515`)
* `WHITELISTED_IPS` - the list of IP addresses to allow to connect to the service (default: `172.17.0.1`, which is the default [bridge network gateway](https://docs.docker.com/network/network-tutorial-standalone/#use-the-default-bridge-network))
* `ALLOWED_ORIGINS` - allowlist of request origins which are allowed to connect to ChromeDriver. The default is `'*'`. You may want to set it to a specific origin to make the service more secure.

#### Examples

Change the port:

```console
docker build -t chch . && docker run -e PORT=8080 -p 8080:8080 --rm chch & docker rmi chch
```

### Security

[`spryker/chromedriver`] may be insecure because of how `chromedriver` is invoked there:

```console
chromedriver --port=4444 --whitelisted-ips --allowed-origins=*
```

It allows any IP to connect to the `chromedriver` service and any origin to send requests to it. This is insecure because it allows anyone to connect to the service and send requests to it.

[`webdriver-downloader`]: https://github.com/ik1ne/webdriver-downloader
[`spryker/chromedriver`]: https://hub.docker.com/r/spryker/chromedriver

## Miscellaneous

<details>
  <summary>The result of `chromedriver --help`</summary>
  
  ```text
Usage: chromedriver [OPTIONS]

Options
  --port=PORT                     port to listen on
  --adb-port=PORT                 adb server port
  --log-path=FILE                 write server log to file instead of stderr, increases log level to INFO
  --log-level=LEVEL               set log level: ALL, DEBUG, INFO, WARNING, SEVERE, OFF
  --verbose                       log verbosely (equivalent to --log-level=ALL)
  --silent                        log nothing (equivalent to --log-level=OFF)
  --append-log                    append log file instead of rewriting
  --replayable                    (experimental) log verbosely and don't truncate long strings so that the log can be replayed.
  --version                       print the version number and exit
  --url-base                      base URL path prefix for commands, e.g. wd/url
  --readable-timestamp            add readable timestamps to log
  --enable-chrome-logs            show logs from the browser (overrides other logging options)
  --bidi-mapper-path              custom bidi mapper path
  --disable-dev-shm-usage         do not use /dev/shm (add this switch if seeing errors related to shared memory)
  --allowed-ips=LIST              comma-separated allowlist of remote IP addresses which are allowed to connect to ChromeDriver
  --allowed-origins=LIST          comma-separated allowlist of request origins which are allowed to connect to ChromeDriver. Using `*` to allow any host origin is dangerous!
```
</details>
