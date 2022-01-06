#Set these to match your environment
.DEFAULT_GOAL:=help
SHELL:=/bin/bash
VERSION=$(shell git rev-parse --short HEAD)
NAME:=project_name
DOCKER_REGISTRY:=docker_registry
BASE_LANG:=go
SRC_DIR:=./
ENV:=dev
TAG:=$(ENV)
BUILD_TYPE:=docker
TESTPATH= ./...
AWS_REGION=aws_region
COVERAGEREPORTHTML=./coverage.html
CONFIGNAME=API_CONF
CONFIGVALUE=../testconfig.json
