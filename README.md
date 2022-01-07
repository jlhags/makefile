# Makefile

A makefile to handle common dev tasks

## Setup
### Install
If you are adding this makefile to your project you will need to run the following commands from inside your gitroot:

```bash
git remote add makefile git@github.com:jlhags/makefile.git
git fetch makefile
git checkout makefile/main makefile
git checkout makefile/main config.mk
```
### Configure
Once installed you should only ever need to manually change the `config.mk` to match your project environment.

#### Config Options
| Option | Description | Example | Default |
| ------ | ----------- | ------- | ------- |
| .DEFAULT_GOAL | default command to run when providing no command | help | help |
| SHELL | the shell to use to run certain commands | /bin/bash | /bin/bash |
| VERSION | the version of the project | $(shell git rev-parse --short HEAD) | git commit id|
| NAME | the name of the project | example | |
| BASE_LANG | the base language of the project | go | go |
| SRC_DIR | the directory where the source code is located e.g | ./src | ./ |
| ENV | the enviroment the project should be build for | dev | dev |
| TAG | the tag that should be added to the container image | $(ENV) | $(ENV)
| BUILD_TYPE | the type of build done for the project | docker | docker |
| TESTPATH | where to find the unit tests | ./... | ./... |
| AWS_REGION | the aws region associated with the project | us-east-1 |
| COVERAGEREPORTHTML | location of where coverage report html should be placed | ./coverage.html | ./coverage.html
| CONFIGNAME | name of config env var to be used | API_CONF | API_CONF
| CONFIG_VALUE | value of config env var | ../testconfig.json | testconfig.json |

# Usage
```bash
make [command]
```
To see the list of available commands run:

```bash
make help
```

