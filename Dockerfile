FROM python:3.8-alpine

RUN apk add --no-cache jq

ENV AWSCLI_VERSION='1.38.7'

RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}

RUN addgroup -g 1000 docker

RUN adduser -u 1000 -G docker -h /home/docker -D docker

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER docker

ENTRYPOINT ["/entrypoint.sh"]