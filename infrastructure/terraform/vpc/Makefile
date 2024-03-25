.PHONY: init plan apply
SHELL := /bin/bash

DEFAULT_ZONE = default
DEFAULT_REGION = eu-west-1


need-ZONE:
ifndef ZONE
	@echo "Using default zone $(DEFAULT_ZONE)"
override ZONE = $(DEFAULT_ZONE)
endif

need-REGION:
ifndef REGION
	@echo "Using default region $(DEFAULT_REGION)"
override REGION = $(DEFAULT_REGION)
endif

fmt:
	terraform fmt -recursive .

fmt-check:
	terraform fmt -check -diff -recursive .

tflint:
	tflint --init --config=$(HOME)/.tflint.hcl && \
    tflint --config=$(HOME)/.tflint.hcl --recursive --color --filter=modules/external

init: need-ZONE need-REGION fmt-check tflint
	./scripts/tf-init.sh $(ZONE) $(REGION)

validate: init
	terraform validate

output: init
	terraform output
	
plan: init
	terraform plan -out ./tf.plan -lock-timeout=120s\
	  -var-file=./configs/$(ZONE)-$(REGION).tfvars \
	  -var-file=./configs/backend/$(ZONE)-$(REGION).sh

apply: init
	terraform apply -lock-timeout=120s\
	  -var-file=./configs/$(ZONE)-$(REGION).tfvars \
	  -var-file=./configs/backend/$(ZONE)-$(REGION).sh

apply-plan: plan
	terraform apply -lock-timeout=120s ./tf.plan

destroy: init
	terraform destroy \
	  -var-file=./configs/$(ZONE)-$(REGION).tfvars \
	  -var-file=./configs/backend/$(ZONE)-$(REGION).sh

import: init
	terraform import \
	  -var-file=./configs/$(ZONE)-$(REGION).tfvars \
	  -var-file=./configs/backend/$(ZONE)-$(REGION).sh \
	  $(PARAMETERS)