#!/bin/bash

#
# This script will be called:
#  - when the coder workspace is built or re-built
#  - every time the coder workspace is started
# It is executed at the very end of workspace setup.

set -euo pipefail
echo "-----------------------------------------"
echo "---- tap-coder-demo-personalizations ----"
echo "-----------------------------------------"

echo "CODER_WORKSPACE_NAME = $CODER_WORKSPACE_NAME"

cd ~/tap-coder-demo/eks
./configure-aws-secrets.sh
./eks-cluster-create.sh

cd ~/tap-coder-demo/tap-install
./install-tap.sh

# echo >~/.aws/config <<EOF
# [default]
# region=us-west-1
# output=json
# EOF

eksctl get cluster --region us-west-1

echo "---------------------------------------------"
echo "---- END tap-coder-demo-personalizations ----"
echo "---------------------------------------------"
