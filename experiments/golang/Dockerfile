#!/bin/bash

FROM golang:1.18
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN env GOOS=linux GOARCH=amd64 go build -o main . 