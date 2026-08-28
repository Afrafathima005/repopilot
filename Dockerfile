# ==============================================================================
# Multi-stage Dockerfile for Autonomous SE Agent Backend
# ==============================================================================

# --- Stage 1: Build dependencies ---
FROM python:3.12-slim AS builder

WORKDIR /build

# Install dependencies required to compile native packages (if any)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration and install dependencies
COPY pyproject.toml .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir .

# --- Stage 2: Final Run Image ---
FROM python:3.12-slim

WORKDIR /app

# Install system dependencies (git for repository cloning, libpq for postgres)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy installed packages from the builder stage
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy codebase
COPY . .

# Set running environment variables
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

EXPOSE 8000

# Run with Uvicorn
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
