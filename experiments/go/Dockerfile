#!/bin/bash

FROM ghcr.io/stargz-containers/golang:1.18-org
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN env GOOS=linux GOARCH=amd64 go build -o main . 