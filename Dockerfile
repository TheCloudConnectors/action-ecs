FROM python:3.8-alpine

RUN apk add --no-cache jq curl

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

RUN addgroup -g 1000 docker

RUN adduser -u 1000 -G docker -h /home/docker -D docker

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER docker

ENTRYPOINT ["/entrypoint.sh"]