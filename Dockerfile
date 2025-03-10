FROM python:3.8-alpine

RUN apk add --no-cache jq curl bash

RUN curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli \
    && rm -rf awscliv2.zip aws \
    && aws --version

RUN addgroup -g 1000 docker

RUN adduser -u 1000 -G docker -h /home/docker -D docker

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER docker

ENTRYPOINT ["/entrypoint.sh"]