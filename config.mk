#Set these to match your environment
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
