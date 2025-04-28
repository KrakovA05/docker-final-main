FROM golang:1.22-alpine AS builder

RUN apk add --no-cache gcc musl-dev

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=1 GOOS=linux go build -ldflags="-w -s" -o /parcel-tracker

FROM alpine:3.19

RUN apk add --no-cache libc6-compat

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

RUN mkdir -p /app/data && \
    chown -R appuser:appgroup /app && \
    chmod -R 750 /app/data

WORKDIR /app

COPY --from=builder --chown=appuser:appgroup /parcel-tracker /app/parcel-tracker

USER appuser

VOLUME /app/data

ENV DB_PATH=/app/data/tracker.db

ENTRYPOINT ["/app/parcel-tracker"]