FROM python:3.8-alpine

# Install system dependencies
RUN apk add --no-cache \
    curl \
    jq \
    unzip \
    gcompat \
    libc6-compat

# Install AWS CLI v2 (version explicite)
RUN curl -sS -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.24.20.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin \
    && rm -rf awscliv2.zip aws \
    && aws --version

# Configuration finale
RUN adduser -u 1000 -D docker
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER docker

ENTRYPOINT ["/entrypoint.sh"]