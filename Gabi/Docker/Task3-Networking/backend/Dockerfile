FROM python:3.11-alpine

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY app.py .
RUN pip install --no-cache-dir flask

USER appuser

EXPOSE 5000

CMD ["python", "app.py"]