#!/bin/bash

if [ $# -lt 5 ]; then
  echo "Usage: $0 <keycloak-host> <keycloak-user> <keycloak-pass> <realm> <app-name>"
  exit 1
fi

keycloak_host=$1
user=$2
pass=$3
realm=$4
app_name=$5

function getToken {
    curl -s \
        -H 'Content-Type:application/x-www-form-urlencoded' \
        -d  username=${2} \
        -d  password=${3} \
        -d  grant_type=password \
        -d  client_id=admin-cli \
        ${1}/auth/realms/master/protocol/openid-connect/token |
    jq '.access_token' -cr
}

function postClient {
    curl -s \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${1}" \
        -d '{
                "clientId": "'${2}'",
                "description": "client create from script",
                "enabled": true,
                "consentRequired": false,
                "protocol": "openid-connect",
                "bearerOnly": false,
                "publicClient": false,
                "standardFlowEnabled": true,
                "implicitFlowEnabled": true,
                "directAccessGrantsEnabled": true,
                "authorizationServicesEnabled": false,
                "serviceAccountsEnabled": false,
                "fullScopeAllowed": false,
                "redirectUris": ["*"],
                "clientAuthenticatorType": "client-secret"
        }' \
        ${3}/auth/admin/realms/${4}/clients
}

function getClientId {
    curl -s \
        -H "Authorization: Bearer ${1}" \
        ${2}/auth/admin/realms/${3}/clients?clientId=${4} |
    jq .[].id -cr
}

function getClientSecret {
    curl -s \
        -H "Authorization: Bearer ${1}" \
        {$2}/auth/admin/realms/{$3}/clients/{$4}/client-secret |
    jq .
}

function addRole {
    curl -s \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${1}" \
        -d '{
            "name": "'${5}'-users",
            "description": "'${5}'-users",
            "composite": false,
            "clientRole": false,
            "containerId": "'{$3}'"
            }' \
        {$2}/auth/admin/realms/{$3}/clients/{$4}/roles |
        jq .
}

postClient $(getToken $keycloak_host $user $pass) $app_name $keycloak_host $realm 

echo -e "\033[31mclient secret is:\033[m"$(getClientSecret $(getToken $keycloak_host $user $pass) $keycloak_host $realm $(getClientId $(getToken $keycloak_host $user $pass) $keycloak_host $realm $app_name) |
jq '.value' -cr)

addRole $(getToken $keycloak_host $user $pass) $keycloak_host $realm $(getClientId $(getToken $keycloak_host $user $pass) $keycloak_host $realm $app_name) $app_name

exit 0
