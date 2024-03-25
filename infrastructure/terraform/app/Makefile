.PHONY: init plan apply
SHELL := /bin/bash

DEFAULT_ENV = dev
DEFAULT_REGION = eu-west-1


need-ENV:
ifndef ENV
	@echo "Using default env $(DEFAULT_ENV)"
override ENV = $(DEFAULT_ENV)
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

init: need-ENV need-REGION fmt-check
	./scripts/tf-init.sh $(ENV) $(REGION)

validate: init
	terraform validate

output: init
	terraform output
	
plan: init
	terraform plan -out ./tf.plan -lock-timeout=120s\
	  -var-file=./configs/$(ENV)-$(REGION).tfvars \
	  -var-file=./configs/backend/$(ENV)-$(REGION).sh

apply: init
	terraform apply -lock-timeout=120s\
	  -var-file=./configs/$(ENV)-$(REGION).tfvars \
	  -var-file=./configs/backend/$(ENV)-$(REGION).sh

apply-plan: plan
	terraform apply -lock-timeout=120s ./tf.plan

destroy: init
	terraform destroy \
	  -var-file=./configs/$(ENV)-$(REGION).tfvars \
	  -var-file=./configs/backend/$(ENV)-$(REGION).sh

import: init
	terraform import \
	  -var-file=./configs/$(ENV)-$(REGION).tfvars \
	  -var-file=./configs/backend/$(ENV)-$(REGION).sh \
	  $(PARAMETERS)