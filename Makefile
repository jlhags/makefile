.DEFAULT_GOAL:=help
SHELL:=/bin/bash
VERSION=$(shell git rev-parse --short HEAD)

include config.mk

##@ Dependencies

.PHONY: deps

deps:  ## Check/get dependencies
ifeq ($(BASE_LANG),go)
	cd $(SRC_DIR); go mod tidy; go mod vendor
else
	$(info Option not available for language)
endif


##@ Test

.PHONY: unit-test functional-test coverage coverage-report

unit-test: ## Run unit tests
ifeq ($(BASE_LANG),go)
	cd $(SRC_DIR); go test $(TESTPATH)
else
	$(info Option not available for language)
endif

coverage: ## Run code coverage coverage-report
ifeq ($(BASE_LANG),go)
	cd $(SRC_DIR);go test -cover $(TESTPATH)
else
	$(info Option not available for language)
endif
coverage-report: coverage ## Create code coverage report
ifeq ($(BASE_LANG),go)
	cd $(SRC_DIR); go test -coverprofile=coverage.out $(TESTPATH)
	cd $(SRC_DIR); go tool cover -html=coverage.out -o $(COVERAGEREPORTHTML)
else
	$(info Option not available for language)
endif
functional-test: ## Run functional tests
ifeq ($(BUILD_TYPE),docker)
	docker-compose  up --build --abort-on-container-exit --exit-code-from functional-test --renew-anon-volumes --remove-orphan functional-test
else
	$(info Option not available for build type)
endif


##@ Cleanup

.PHONY: clean

clean: ## Cleanup the project folders
	$(info Cleaning up things)

##@ Building

.PHONY: build publish run

build: clean deps ## Build the project
ifeq ($(BUILD_TYPE),docker)
	docker build --build-arg GITHUB_TOKEN --build-arg GITHUB_LOGIN -t $(REGISTRY)/$(NAME):$(VERSION) -f Dockerfile . 
	docker tag $(REGISTRY)/$(NAME):$(VERSION) $(REGISTRY)/$(NAME):$(TAG)
else
	$(info Option not available for build type)
endif

publish: docker-login ## Publish the project
ifeq ($(BUILD_TYPE),docker)
	docker push $(REGISTRY)/$(NAME):$(VERSION)
	docker push $(REGISTRY)/$(NAME):$(TAG)
else
	$(info Option not available for build type)
endif

run: ## Run the project locally
ifeq ($(BASE_LANG),go)
	cd $(SRC_DIR); ENV=dev $(CONFIGNAME)=$(CONFIGVALUE) AWS_REGION=$(AWS_REGION) go run ./main.go
else
	$(info Option not available for language)
endif



docker-login:
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(REGISTRY)
	aws ecr-public get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin public.ecr.aws


##@ Helpers

.PHONY: help

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
