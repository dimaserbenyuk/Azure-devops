FROM amazonlinux:2023.7.20250623.1

RUN dnf install -y \
    unzip \
    jq \
    python3 \
    less \
    shadow-utils \
    && dnf clean all

ENV STACK_NAMES=""
ENV ACTIVE=""
ENV AWS_REGION=""
ENV AWS_CLI_VERSION="2.15.58"

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        CLI_ARCH="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        CLI_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-${CLI_ARCH}-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

RUN python3 -m ensurepip && \
    pip3 install --upgrade pip && \
    pip3 install --upgrade setuptools==70.0.0

WORKDIR /app

COPY ecs_toggle.sh /app/ecs_toggle.sh
RUN chmod +x /app/ecs_toggle.sh

ENTRYPOINT ["/bin/bash", "/app/ecs_toggle.sh"]
