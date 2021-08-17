FROM golang:1.16.6 AS build
WORKDIR /app/src
COPY *.go ./
ARG GOOS=linux
ARG GOARCH=amd64
ARG CGO_ENABLED=0
RUN go build -o webgo *.go

FROM alpine:3.12.0
WORKDIR /
RUN apk add --update ca-certificates # Certificates for SSL
COPY --from=build /app/src/webgo ./
ENTRYPOINT /webgo
