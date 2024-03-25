#!/usr/bin/env bash

REGION=eu-west-1
TERRAFORM_DYNAMODB_NAME=terraform-aws-eks-app-state-${REGION}

aws dynamodb list-tables --output table

aws dynamodb create-table \
  --region ${REGION} \
  --table-name ${TERRAFORM_DYNAMODB_NAME} \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1