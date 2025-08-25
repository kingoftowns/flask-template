FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    git \
    make \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -ms /bin/bash vscode && \
    mkdir -p /workspace && \
    chown -R vscode:vscode /workspace

# Set working directory
WORKDIR /workspace

# Copy requirements file
COPY src/__APP_NAME__/requirements.in /tmp/requirements.in

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install pip-tools && \
    pip-compile /tmp/requirements.in -o /tmp/requirements.txt && \
    pip install -r /tmp/requirements.txt && \
    pip install debugpy black ipython celery[redis] flower

# Switch to non-root user
USER vscode

# Set Python path
ENV PYTHONPATH=/workspace:$PYTHONPATH
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1