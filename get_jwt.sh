#!/bin/bash

# Check cmd arguments
if [ $# -lt 6 ]; then
  echo "Error: Usage: $0 <keycloak-url> <ldap-user> <ldap-pass> <realm> <app-name> <client-secret>"
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
user=$2
pass=$3
realm=$4
appName=$5
clientSecret=$6
curlFlags="-s"

source $common

# Get id and set it to global var

accessToken=$(GetJwt $clientSecret)

# Make result output
echo '{"client_name":"'$appName'","access_token":"'$accessToken'"}' \
| jq .

exit 0
