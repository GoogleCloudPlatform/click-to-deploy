FROM gcr.io/google-appengine/debian9:latest
#FROM node:alpine

MAINTAINER Charles Vallance <vallance.charles@gmail.com>

WORKDIR /opt/cvallance/mongo-k8s-sidecar

COPY package.json /opt/cvallance/mongo-k8s-sidecar/package.json

RUN apt-get update && \
	apt-get -y install \
		curl \
		gnupg\
	&& curl -sL https://deb.nodesource.com/setup_8.x | bash - \
	&& apt-get -y install \
		build-essential \
		nodejs

RUN npm install

COPY ./src /opt/cvallance/mongo-k8s-sidecar/src
COPY .foreverignore /opt/cvallance/.foreverignore

CMD ["npm", "start"]
