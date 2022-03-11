#!/bin/bash

# GetToken  - for calling
function GetToken {
    curl ${curlFlags} \
        -H 'Content-Type:application/x-www-form-urlencoded' \
        -d  username=${adminLogin} \
        -d  password=${adminPass} \
        -d  grant_type=password \
        -d  client_id=admin-cli \
        ${host}/auth/realms/master/protocol/openid-connect/token \
    | jq '.access_token' -cr
}

# PostClient $token  - for calling
function PostClient {
    curl ${curlFlags} \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${token}" \
        -d '{
                "clientId": "'${appName}'",
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
        ${host}/auth/admin/realms/${realm}/clients \
    1> /dev/null
}

# GetClientId $token   - for calling
function GetClientId {
    curl ${curlFlags} \
        -H "Authorization: Bearer ${token}" \
        ${host}/auth/admin/realms/${realm}/clients?clientId=${appName} \
    | jq .[].id -cr
}

# GetClientSecret $token $clientId  - for calling
function GetClientSecret {
    curl ${curlFlags} \
        -H "Authorization: Bearer ${token}" \
        ${host}/auth/admin/realms/${realm}/clients/${clientId}/client-secret \
    | jq .value -cr
}

# AddRole $token $clientId  - for calling
function AddRole {
    curl ${curlFlags} \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${token}" \
        -d '{
                "name": "'${appName}'-users",
                "description": "Role '${appName}'-users for LDAP group",
                "composite": false,
                "clientRole": false,
                "containerId": "'${realm}'"
        }' \
        ${host}/auth/admin/realms/${realm}/clients/${clientId}/roles \
    1> /dev/null
}

# GetJwt function for get user jwt token
function GetJwt {
    curl ${curlFlags} \
        -H "Content-Type:application/x-www-form-urlencoded" \
        -d  username=${user} \
        -d  password=${pass} \
        -d  grant_type=password \
        -d  client_id=${appName} \
        -d  client_secret=${clientSecret} \
    ${host}/auth/realms/${realm}/protocol/openid-connect/token \
    | jq .access_token -cr
}
