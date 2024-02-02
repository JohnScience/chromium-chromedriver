FROM rust:latest as builder

RUN apt-get update && \
    apt-get install -y musl-tools openssl git && \
    rm -rf /var/lib/apt/lists/*
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /
RUN rustup show | grep 'default' | awk -F'-' '{print $2}' > arch.txt
RUN git clone --depth=1 https://github.com/JohnScience/webdriver-downloader
WORKDIR /webdriver-downloader/webdriver-downloader-cli
RUN cargo build --no-default-features -F rustls-tls --target x86_64-unknown-linux-musl --release

# Use a slim image for running the application
FROM alpine as runtime

ARG PORT=9515
ENV PORT=$PORT

RUN apk add gcompat chromium
RUN apk add curl

COPY --from=builder /webdriver-downloader/target/x86_64-unknown-linux-musl/release/webdriver-downloader /bin/webdriver-downloader
COPY --from=builder /arch.txt /arch.txt

ENV ARCH="$(cat /arch.txt)"


RUN webdriver-downloader --skip-verify --type chrome --driver /bin/chromedriver

EXPOSE $PORT

# ENTRYPOINT [ "sh", "-c", "echo ${ARCH}" ]
ENTRYPOINT [ "sh", "-c", "chromedriver --verbose --port $PORT" ]
# ENTRYPOINT [ "sh", "-c", "chromedriver --verbose" ]
# ENTRYPOINT [ "sh", "-c", "echo $PORT" ]
