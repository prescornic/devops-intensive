# Stage 1: Builder
FROM golang:1.21 AS builder

WORKDIR /build

COPY go.mod ./
RUN go mod download

COPY cmd ./cmd

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o app ./cmd/app

# Stage 2: Runtime
FROM alpine:3.20

LABEL maintainer="Gabriel Lupascu" \
      version="1.0.0" \
      description="Multi-stage Go application build"

ENV APP_PORT=8080 \
    APP_ENV=production

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

RUN apk add --no-cache wget

COPY --from=builder /build/app /app/app

RUN chown appuser:appgroup /app/app

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --spider --quiet http://127.0.0.1:8080/health || exit 1

CMD ["./app"]