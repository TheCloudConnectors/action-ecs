FROM amazon/aws-cli:2.24.20

# Install additional dependencies
RUN yum install -y jq

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]