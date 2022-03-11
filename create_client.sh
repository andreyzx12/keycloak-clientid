#!/bin/bash

# Check cmd arguments
if [ $# -lt 5 ]; then
  echo "Error: Usage: $0 <keycloak-url> <admin_login> <admin-pass> <realm> <app-name>"
  exit 1
fi

# Сheck required utility dependencies
if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed' >&2
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed' >&2
  exit 1
fi

# Include file with functions
common="_common.sh"
if ! [ -f "$common" ]; then
  echo "Error: $common file does not exist" >&2
  exit 1
fi

# Define global vars
host=$1
adminLogin=$2
adminPass=$3
realm=$4
appName=$5
curlFlags="-s"

source $common

# Get token and set it to global var
token=$(GetToken)

# Сreate new client for app with no output if errors less
PostClient $token

# Get id and set it to global var
clientId=$(GetClientId $token)

# Add role to client with no output if errors less
AddRole $token $clientId

# Make result output
echo '{"client_name":"'$appName'","client_id":"'$clientId'","client_role":"'$appName'-users"}' \
| jq .

exit 0
