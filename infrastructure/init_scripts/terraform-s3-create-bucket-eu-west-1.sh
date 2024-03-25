#!/usr/bin/env bash

AWS_ACCOUNT_NAME=changeme
REGION=eu-west-1
BUCKET=${AWS_ACCOUNT_NAME}-terraform-aws-eks-app-state-${REGION}

if ! aws s3 ls ${BUCKET} >/dev/null 2>&1; then 
  aws s3api create-bucket \
    --bucket "${BUCKET}" \
    --create-bucket-configuration LocationConstraint=${REGION} \
    --region ${REGION} | jq .
  aws s3api put-bucket-versioning \
    --bucket "${BUCKET}" \
    --versioning-configuration "MFADelete=Disabled,Status=Enabled"
fi

