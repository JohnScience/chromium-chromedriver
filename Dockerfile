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

ARG PORT=9515
ENV PORT=$PORT

RUN apk add gcompat chromium
RUN apk add curl

COPY --from=builder /arch.txt /arch.txt
COPY --from=builder /target.txt /target.txt
COPY --from=builder /webdriver-downloader/target/arch-unknown-linux-musl/release/webdriver-downloader /bin/webdriver-downloader

RUN webdriver-downloader --skip-verify --type chrome --driver /bin/chromedriver

EXPOSE $PORT

RUN echo -n 'chromedriver --verbose --port ' > command.txt && \
    echo $PORT >> command.txt

ENTRYPOINT [ "sh", "-c", "cat command.txt" ]
# ENTRYPOINT [ "sh", "-c", "cat command.txt | sh" ]
