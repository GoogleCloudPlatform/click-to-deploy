# Clone git repo
FROM alpine/git:1.0.7 as git

ENV NUCLIO_VERSION=1.1.33

RUN git clone https://github.com/nuclio/nuclio.git /src/nuclio/ \
    && cd /src/nuclio/ \
    && git checkout $NUCLIO_VERSION \
    && echo "{\"git_commit\": \"$(git rev-parse HEAD)\", \"label\": \"$NUCLIO_VERSION\", \"os\": \"linux\", \"arch\": \"amd64\"}" > /version_info.json \
    && cat  /version_info.json


FROM golang:1.10 as builder

COPY --from=git /src/nuclio  /go/src/github.com/nuclio/nuclio

WORKDIR /go/src/github.com/nuclio/nuclio

# build the controller
RUN go get -u github.com/kardianos/govendor \
    && go get github.com/v3io/v3io-go-http \
    && go get github.com/nuclio/logger \
    && go get github.com/nuclio/nuclio-sdk-go \
    && go get github.com/nuclio/amqp \
    && govendor license +vendor > NOTICES \
    && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags="-s -w" -o controller cmd/controller/main.go


# Result Image
FROM gcr.io/google-appengine/debian9:latest

ENV C2D_RELEASE=1.1.33

# Binaries
COPY --from=builder /go/src/github.com/nuclio/nuclio/controller /usr/local/bin

# Version file
COPY --from=git /version_info.json /etc/nuclio/version_info.json

# License and Notices
COPY --from=builder /go/src/github.com/nuclio/nuclio/NOTICES /usr/share/nuclio/NOTICES
COPY --from=builder /go/src/github.com/nuclio/nuclio/LICENSE /usr/share/nuclio/LICENSE

CMD [ "controller" ]
