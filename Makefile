include config.mk
MREMOTE=$(shell git remote | grep makefile)
PWD=$(shell pwd)
##@ Dependencies

.PHONY: deps

deps:  ## Check/get dependencies
ifeq ($(BASE_LANG),go)
	cd $(SRC_DIR); go mod tidy && go mod vendor
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
	cd $(SRC_DIR);go test -coverprofile=$(PWD)/coverage.out $(TESTPATH)
else
	$(info Option not available for language)
endif
coverage-report: coverage ## Create code coverage report
ifeq ($(BASE_LANG),go)
	cd $(SRC_DIR); go tool cover -html=$(PWD)/coverage.out -o $(PWD)/$(COVERAGEREPORTHTML)
else
	$(info Option not available for language)
endif
functional-test: ## Run functional tests
ifeq ($(BUILD_TYPE),docker)
	docker-compose  up --build --abort-on-container-exit --exit-code-from functional-test --renew-anon-volumes --remove-orphan
else
	$(info Option not available for build type)
endif


##@ Cleanup

.PHONY: clean

clean: ## Cleanup the project folders
	$(info Cleaning up things)
ifeq ($(BASE_LANG),go)
	rm -f coverage.html
else
        $(info Option not available for language)
endif
##@ Building

.PHONY: build publish run

build: clean deps ## Build the project
ifeq ($(BUILD_TYPE),docker)
	docker buildx build --build-arg GITHUB_TOKEN --build-arg GITHUB_LOGIN -t $(DOCKER_REGISTRY)/$(NAME):$(VERSION) -f Dockerfile . 
	docker tag $(DOCKER_REGISTRY)/$(NAME):$(VERSION) $(DOCKER_REGISTRY)/$(NAME):$(TAG)
else
	$(info Option not available for build type)
endif

publish: docker-login ## Publish the project
ifeq ($(BUILD_TYPE),docker)
	docker push $(DOCKER_REGISTRY)/$(NAME):$(VERSION)
	docker push $(DOCKER_REGISTRY)/$(NAME):$(TAG)
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
	aws ecr get-login-password --region $(AWS__DEFAULT_REGION) | docker login --username AWS --password-stdin $(DOCKER_REGISTRY)
	aws ecr-public get-login-password --region $(AWS_DEFAULT_REGION) | docker login --username AWS --password-stdin public.ecr.aws


##@ Helpers

.PHONY: help update-makefile

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

addmakefilerepo:
ifeq ($(MREMOTE),)
	git remote add makefile git@github.com:jlhags/makefile.git
endif

update-makefile: addmakefilerepo ## Get latest version of makefile
	git fetch makefile
	git checkout makefile/main Makefile
