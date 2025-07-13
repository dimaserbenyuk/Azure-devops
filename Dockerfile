FROM amazonlinux:2023

# Установим зависимости
RUN dnf install -y \
    unzip \
    # curl \
    jq \
    python3 \
    less \
    shadow-utils \
    && dnf clean all

# Версия AWS CLI — можно задать переменной для удобства обновления
ENV AWS_CLI_VERSION="2.15.58"

# Установка AWS CLI
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

# Обновляем pip (если нужно для python)
RUN python3 -m ensurepip && pip3 install --upgrade pip

# Создание директории приложения
WORKDIR /app

# Копируем скрипт
COPY ecs_toggle.sh /app/ecs_toggle.sh
RUN chmod +x /app/ecs_toggle.sh

# Переменные окружения (могут быть переопределены)
ENV STACK_NAMES=""
ENV ACTIVE=""
ENV AWS_REGION=""

ENTRYPOINT ["/bin/bash", "/app/ecs_toggle.sh"]
# CMD [ "sleep", "36000" ]