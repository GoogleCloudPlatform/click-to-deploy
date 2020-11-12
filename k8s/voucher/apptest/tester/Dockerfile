FROM alpine:3.8

RUN apk --no-cache add curl

COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
