FROM python:3.11-slim

WORKDIR /app

# Optional system deps (handy for scientific wheels)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

# Copy model artifacts and API code
COPY models models
COPY src src

# Install runtime dependencies (now includes scikit-learn)
RUN pip install --no-cache-dir fastapi uvicorn pandas joblib pydantic scikit-learn

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "src.api:app", "--host", "0.0.0.0", "--port", "8000"]
