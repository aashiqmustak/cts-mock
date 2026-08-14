# Use light-weight Python base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Set workspace working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency requirements
COPY requirements.txt /app/

# Install python dependencies with extended connection timeout
RUN pip install --no-cache-dir --default-timeout=100 -r requirements.txt

# Copy application source code
COPY src/ /app/src/
COPY models/ /app/models/
COPY rules/ /app/rules/
COPY uploads/ /app/uploads/

# Expose API port
EXPOSE 8000

# Start command
CMD ["uvicorn", "src.api.api:app", "--host", "0.0.0.0", "--port", "8000"]
