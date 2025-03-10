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
    libffi-dev \
    python3-dev \
    g++

# Create virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install AWS CLI in virtual environment
RUN pip3 install --no-cache-dir awscli==2.24.20

# Verify installation
RUN aws --version

# Configuration finale
RUN adduser -u 1000 -D docker
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER docker

ENTRYPOINT ["/entrypoint.sh"]