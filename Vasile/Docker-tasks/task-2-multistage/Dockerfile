# STAGE 1: Builder
FROM python:3.11-slim as builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# STAGE 2: Runtime
FROM python:3.11-slim-bookworm

LABEL author="Vasile" version="2.0.0" description="Multistage"

WORKDIR /app

RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Copy only the installed packages from the builder stage
# Python stores '--user' installs in .local/
COPY --from=builder /root/.local /home/appuser/.local
COPY app.py .

# Ensure the local binaries are in the PATH
ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

RUN chown -R appuser:appgroup /app

USER appuser

# Healthcheck requirement
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:5000/health || exit 1

EXPOSE 5000

CMD ["python", "app.py"]