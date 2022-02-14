#!/bin/bash
set -euo pipefail
echo "-----------------------------------------"
echo "---- tap-coder-demo-personalizations ----"
echo "-----------------------------------------"

cd ~/tap-coder-demo/eks
./configure-aws-secrets.sh

# echo >~/.aws/config <<EOF
# [default]
# region=us-west-1
# output=json
# EOF

eksctl get cluster --region us-west-1

echo "---------------------------------------------"
echo "---- END tap-coder-demo-personalizations ----"
echo "---------------------------------------------"
