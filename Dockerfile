FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM rust:alpine as builder
COPY --from=xx / /
RUN apk add clang lld git && \
    rm -rf /var/lib/apt/lists/*
ARG TARGETPLATFORM

RUN git clone --depth=1 https://github.com/JohnScience/webdriver-downloader
WORKDIR /webdriver-downloader/webdriver-downloader-cli
RUN xx-cargo build --no-default-features -F rustls-tls --release --target-dir ./build && \
    xx-verify ./build/$(xx-cargo --print-target-triple)/release/webdriver-downloader && \
    mv ./build/$(xx-cargo --print-target-triple) ./build/target_triple

FROM --platform=$BUILDPLATFORM alpine:latest
RUN apk add chromium gcompat
COPY --from=builder /webdriver-downloader/webdriver-downloader-cli/build/target_triple/release/webdriver-downloader webdriver-downloader

RUN ./webdriver-downloader --skip-verify --type chrome --driver /bin/chromedriver

ENV PORT=9515
ENV WHITELISTED_IPS="172.17.0.1"
ENV ALLOWED_ORIGINS="'*'"

# 172.17.0.1 is a bridge network gateway
ENTRYPOINT [ "sh", "-c", "echo 'chromedriver --port=$PORT --whitelisted-ips=$WHITELISTED_IPS --allowed-origin=$ALLOWED_ORIGINS' | sh" ]

# ENTRYPOINT [ "sh", "-c", "ls build/$(xx-cargo --print-target-triple)/release" ]