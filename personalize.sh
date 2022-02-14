#!/bin/bash
set -euo pipefail
echo "-----------------------------------------"
echo "---- tap-coder-demo-personalizations ----"
echo "-----------------------------------------"

if [ -z "$CG_CLIENT_ID" ]; then 
    echo "CG_CLIENT_ID env var must be provided. Please add it to your .profile in your 'dotfiles' repo".
    exit 99
fi

if [ -z "$CG_CLIENT_ID" ]; then 
    echo "CG_CLIENT_SECRET env var must be provided. Please add it to your .profile in your 'dotfiles' repo".
    exit 99
fi

echo "Cloudgate Client ID:     $CG_CLIENT_ID"

CG_API_TOKEN=$(curl -s --location --request POST 'https://api.console.cloudgate.vmware.com/authn/token' \
  --user "${CG_CLIENT_ID}:${CG_CLIENT_SECRET}" \
  --header 'Content-Type: application/json' \
  --data-raw '{ "grant_type": "client_credentials" }' | jq -r .access_token)

echo "CG API Token: $CG_API_TOKEN"

CG_ACCESS=$(curl -s 'https://api.console.cloudgate.vmware.com/access/access' \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  -H "authorization: Bearer ${CG_API_TOKEN}" \
  --data-raw '{"ouId":"ou-kw69-lqh1erao","orgAccountId":"002159642820","role":"PowerUser","masterAccountId":"116462199383"}')

echo "$CG_ACCESS" | jq

AWS_ACCESS_KEY_ID=$(echo "$CG_ACCESS" | jq -r ".credentials.accessKeyId")
AWS_SECRET_KEY_ID=$(echo "$CG_ACCESS" | jq -r ".credentials.secretAccessKey")
AWS_SESSION_TOKEN=$(echo "$CG_ACCESS" | jq -r ".credentials.sessionToken")

echo "AWS Access Key ID: $AWS_ACCESS_KEY_ID"
echo "AWS Secret Key ID: $AWS_SECRET_KEY_ID"
echo "AWS Session Token: $AWS_SESSION_TOKEN"

mkdir -p ~/.aws
cd ~/.aws

echo >~/.aws/credentials <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_KEY_ID}
aws_session_token=${AWS_SESSION_TOKEN}
EOF

echo >~/.aws/config <<EOF
[default]
region=us-west-1
output=json
EOF