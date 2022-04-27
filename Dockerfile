# syntax=docker/dockerfile:1
FROM golang:1.17-alpine as build

RUN apk add --no-cache git openssh-client
ENV GO111MODULE="on"
ENV CGO_ENABLED="0"

RUN mkdir -m 700 /root/.ssh; \
  touch -m 600 /root/.ssh/known_hosts; \
  ssh-keyscan github.com > /root/.ssh/known_hosts
RUN git config --global --add url."git@github.com:".insteadOf "https://github.com/"

WORKDIR /workspace
COPY go.mod go.mod

RUN go mod download

COPY main.go main.go

# ./... excludes the vendor directory implicitly
RUN go test -short ./...

RUN go build -ldflags="-s -w" -o app

# lite image, from build
FROM alpine:3
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

WORKDIR /opt/app/
COPY --from=build /workspace/app app

ENTRYPOINT ["/opt/app/app"]
