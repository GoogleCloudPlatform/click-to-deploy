# Clone git repo
FROM alpine/git:1.0.7 as git

ENV NUCLIO_VERSION=1.1.33

RUN git clone https://github.com/nuclio/nuclio.git /src/nuclio/ \
    && cd /src/nuclio/ \
    && git checkout $NUCLIO_VERSION \
    && echo "{\"git_commit\": \"$(git rev-parse HEAD)\", \"label\": \"$NUCLIO_VERSION\", \"os\": \"linux\", \"arch\": \"amd64\"}" > /version_info.json \
    && cat  /version_info.json


# Build NodeJS
FROM node:8 as build-static

COPY --from=git /src/nuclio /src/nuclio

RUN npm update -g \
    && npm install -g gulp \
    && cd /src/nuclio/pkg/dashboard/ui \
    && rm -rf ./dist ./node_modules ./resources/*/node_modules \
    && npm install --production \
    && gulp build --production


# Build Go binaries
FROM golang:1.10 as build-binary

COPY --from=git /src/nuclio  /go/src/github.com/nuclio/nuclio

WORKDIR /go/src/github.com/nuclio/nuclio

RUN go get -u github.com/kardianos/govendor \
    && go get github.com/v3io/v3io-go-http \
    && go get github.com/nuclio/logger \
    && go get github.com/nuclio/nuclio-sdk-go \
    && go get github.com/nuclio/amqp \
    && govendor license +vendor > NOTICES \
    && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags="-s -w" -o dashboard cmd/dashboard/main.go


# Result Image
FROM gcr.io/google-appengine/debian9:latest

ARG DOCKER_CLI_VERSION="17.09.0-ce"

ENV DOWNLOAD_URL="https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_CLI_VERSION.tgz"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
               git ca-certificates curl supervisor nginx \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /tmp/download \
    && curl -L $DOWNLOAD_URL | tar -xz -C /tmp/download \
    && mv /tmp/download/docker/docker /usr/local/bin/ \
    && rm -rf /tmp/download

# Copy supervisord configuration files
COPY --from=build-static /src/nuclio/cmd/dashboard/docker/supervisor.conf /etc/supervisor.conf
COPY --from=build-static /src/nuclio/cmd/dashboard/docker/dashboard.sv.conf /etc/supervisor/conf.d/dashboard.conf

# Copy nginx config
COPY --from=build-static /src/nuclio/cmd/dashboard/docker/nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build-static /src/nuclio/pkg/dashboard/ui/dist /etc/nginx/static/
COPY --from=build-binary /go/src/github.com/nuclio/nuclio/dashboard /usr/local/bin

# Copy version file
COPY --from=git /version_info.json /etc/nuclio/version_info.json

# License and Notices
COPY --from=build-binary /go/src/github.com/nuclio/nuclio/NOTICES /usr/share/nuclio/NOTICES
COPY --from=build-binary /go/src/github.com/nuclio/nuclio/LICENSE /usr/share/nuclio/LICENSE

CMD ["supervisord", "-c", "/etc/supervisor.conf", "-l", "/etc/supervisor.log", "-j", "/etc/supervisor.pid"]
