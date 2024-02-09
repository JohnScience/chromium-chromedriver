FROM rust:latest as builder

RUN apt-get update && \
    apt-get install -y musl-tools openssl git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
RUN rustup show | grep 'default' | awk -F'-' '{print $2}' > arch.txt
RUN rustup show | grep 'default' | awk -F'-' '{print $2"-unknown-linux-musl"}' > target.txt

RUN rustup target add $(cat /target.txt)

RUN git clone --depth=1 https://github.com/JohnScience/webdriver-downloader
WORKDIR /webdriver-downloader/webdriver-downloader-cli
RUN cargo build --no-default-features -F rustls-tls --target $(cat /target.txt) --release
# we unify the target dir across various architectures
RUN mv /webdriver-downloader/target/$(cat /target.txt) /webdriver-downloader/target/arch-unknown-linux-musl

# Use a slim image for running the application
FROM alpine as runtime

RUN apk add gcompat chromium
RUN apk add curl

COPY --from=builder /webdriver-downloader/target/arch-unknown-linux-musl/release/webdriver-downloader /bin/webdriver-downloader

RUN webdriver-downloader --skip-verify --type chrome --driver /bin/chromedriver

ENV PORT=9515
ENV WHITELISTED_IPS="172.17.0.1"
ENV ALLOWED_ORIGINS="'*'"

# 172.17.0.1 is a bridge network gateway
ENTRYPOINT [ "sh", "-c", "echo 'chromedriver --port=$PORT --whitelisted-ips=$WHITELISTED_IPS --allowed-origin=$ALLOWED_ORIGINS' | sh" ]
