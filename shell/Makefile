SHELL := /bin/bash
$(eval GIT_REPO_ROOT=$(shell git rev-parse --show-toplevel))

DEFAULT_REGION = eu-west-1
IMAGE = shell
BASE = public.ecr.aws/ubuntu/ubuntu:22.04
USER_NAME = shell

.PHONY: all
all: build

.PHONY: build
build:
	docker build -t $(IMAGE) \
		--build-arg BASE=$(BASE) \
		--build-arg USER_NAME=$(USER_NAME) \
		. 

.PHONY: shell
shell: build
	docker run --rm \
		--workdir "${DOCKER_CWD:-"/repo/infrastructure"}" \
		-v "$(GIT_REPO_ROOT):/repo" \
		-v ${HOME}/.kube:/home/shell/.kube:Z \
		-v ${HOME}/.aws:/home/shell/.aws:Z \
		-v ${HOME}/.bash_history:/home/shell/.bash_history:Z \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-it ${IMAGE}; \





