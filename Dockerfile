FROM alpine:3.21.3

# Install system dependencies with glibc compatibility
RUN apk add --no-cache \
    curl \
    jq \
    unzip \
    gcompat \
    libc6-compat \
    libstdc++ \
    libgcc \
    openssl \
    python3 \
    py3-pip \
    libffi-dev

# Install AWS CLI via pip (version compatible with Alpine)
RUN pip3 install --no-cache-dir awscli==2.24.20

# Verify installation
RUN aws --version

# Configuration finale
RUN adduser -u 1000 -D docker
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER docker

ENTRYPOINT ["/entrypoint.sh"]