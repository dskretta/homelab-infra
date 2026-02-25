#!/bin/bash
set -e

source .env

export VAULT_TOKEN=$VAULT_BOOTSTRAP_TOKEN

echo "Requesting wrapped Secret ID..."
WRAPPED=$(bao write -wrap-ttl=120s \
    -f auth/approle/role/terraform/secret-id \
    -format=json | jq -r '.wrap_info.token')

echo "Unwrapping Secret ID..."
UNWRAPPED=$(bao unwrap -format=json $WRAPPED | jq -r '.data.secret_id')

export TF_VAR_role_id=$VAULT_ROLE_ID
export TF_VAR_secret_id=$UNWRAPPED
export TF_VAR_proxmox_endpoint=$TF_VAR_proxmox_endpoint

echo "Variables exported and ready. Run your Terraform scripts"
