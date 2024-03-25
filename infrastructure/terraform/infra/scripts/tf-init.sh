#!/usr/bin/env bash

set -euo pipefail

ZONE=${1:-default}
REGION=${2:-eu-west-1}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"

source $SCRIPT_DIR/../configs/backend/$ZONE-$REGION.sh

terraform init \
    -backend-config="bucket=${tf_bucket}" \
    -backend-config="key=${tf_key}" \
    -backend-config="region=${REGION}" \
    -backend-config="dynamodb_table=${dynamodb_table}" \
    -lock-timeout=120s \
    -reconfigure

terraform  workspace select -or-create=true $ZONE
echo $REGION
terraform workspace show