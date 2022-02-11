#!/bin/bash
source ./secrets.sh
export CG_API_TOKEN=$(curl -s --location --request POST 'https://api.console.cloudgate.vmware.com/authn/token' \
--user "${CG_CLIENT_ID}:${CG_CLIENT_SECRET}" \
--header 'Content-Type: application/json' \
--data-raw '{ "grant_type": "client_credentials" }' | jq -r .access_token)

curl -s 'https://api.console.cloudgate.vmware.com/access/access' \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  -H "authorization: Bearer ${CG_API_TOKEN}" \
  --data-raw '{"ouId":"ou-kw69-lqh1erao","orgAccountId":"002159642820","role":"PowerUser","masterAccountId":"116462199383"}' > /tmp/cg-access.json

#jq < /tmp/cg-access.json

export AWS_ACCESS_KEY_ID=$(jq -r .credentials.accessKeyId /tmp/cg-access.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r .credentials.secretAccessKey /tmp/cg-access.json)
export AWS_SESSION_TOKEN=$(jq -r .credentials.sessionToken /tmp/cg-access.json)
