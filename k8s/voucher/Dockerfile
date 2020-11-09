# Builder
FROM golang:1.15-alpine as builder

WORKDIR /go/src/github.com/grafeas/voucher
COPY . .
RUN apk --no-cache add \
    git \
    make && \
    make voucher_server

# Final build
FROM alpine:3.8

COPY --from=builder /go/src/github.com/grafeas/voucher/build/voucher_server /usr/local/bin/voucher_server
COPY --from=builder /go/src/github.com/grafeas/voucher/marketplace/entrypoint.sh /usr/local/entrypoint.sh
COPY --from=builder /go/src/github.com/grafeas/voucher/marketplace/config.toml.template /usr/local/config.toml.template

COPY --from=builder /go/src/github.com/grafeas/voucher/third_party /third_party

RUN apk add --no-cache \
    ca-certificates && \
    addgroup -S -g 10000 voucher && \
    adduser -S -u 10000 -G voucher voucher

RUN chown -R 10000:10000 /usr/local/

USER 10000:10000

ENTRYPOINT ["/usr/local/entrypoint.sh"]
