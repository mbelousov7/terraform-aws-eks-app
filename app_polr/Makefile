SHELL := /bin/bash

DEFAULT_REGION = eu-west-1
IMAGE = polr
IMAGE_TAG = latest

.PHONY: all
all: build

.PHONY: build
build:
	docker build -t $(IMAGE) \
		. 

push: build
	$(eval AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text))
	aws ecr get-login-password --region ${DEFAULT_REGION} | docker login --username AWS --password-stdin "$(AWS_ACCOUNT_ID).dkr.ecr.$(DEFAULT_REGION).amazonaws.com"
	$(eval IMAGE_NAME := "${AWS_ACCOUNT_ID}.dkr.ecr.${DEFAULT_REGION}.amazonaws.com/$(IMAGE):$(IMAGE_TAG)")
	docker tag $(IMAGE) $(IMAGE_NAME)
	docker push $(IMAGE_NAME)

destroy:
	aws ecr delete-repository --repository-name $(IMAGE) --force