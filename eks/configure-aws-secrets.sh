#!/bin/bash
set -euo pipefail
if [ -f ~/.cg_secrets.sh ]; then
    source ~/.cg_secrets.sh
else
    echo 'Please add ~/.cg_secrets to your dotfiles and use it to define CG_CLIENT_ID and CG_CLIENT_SECRET'
fi

echo "Cloudgate Client ID:     $CG_CLIENT_ID"

CG_API_TOKEN=$(curl -s --location --request POST 'https://api.console.cloudgate.vmware.com/authn/token' \
  --user "${CG_CLIENT_ID}:${CG_CLIENT_SECRET}" \
  --header 'Content-Type: application/json' \
  --data-raw '{ "grant_type": "client_credentials" }' | jq -r .access_token)

curl -s 'https://api.console.cloudgate.vmware.com/access/access' \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  -H "authorization: Bearer ${CG_API_TOKEN}" \
  --data-raw '{"ouId":"ou-kw69-lqh1erao","orgAccountId":"002159642820","role":"PowerUser","masterAccountId":"116462199383"}' > /tmp/cg-access.json

AWS_ACCESS_KEY_ID=$(jq -r .credentials.accessKeyId /tmp/cg-access.json)
AWS_SECRET_ACCESS_KEY=$(jq -r .credentials.secretAccessKey /tmp/cg-access.json)
AWS_SESSION_TOKEN=$(jq -r .credentials.sessionToken /tmp/cg-access.json)

mkdir -p ~/.aws
envsubst >  ~/.aws/credentials << EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
aws_session_token=${AWS_SESSION_TOKEN}
EOF