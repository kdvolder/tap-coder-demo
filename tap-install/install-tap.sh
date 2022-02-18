#!/bin/bash

set -euo pipefail

# This script is the 'starting point' that runs all the rest.

# Relevant docs:
# https://docs-staging.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-overview.html

# You must edit the variables below and fill in your own credentials
# It is recommended that you:
#  - make a copy of this file and keep this one unmodified to avoid committing secrets to git
#  - add your copied file to .gitignore (to avoid committing secrets to git)

if [ -f ~/.tanzu-secrets.sh ]; then
    source ~/.tanzu-secrets.sh
else
    echo "Cannot install TAP because ~/.tanzu-secrets.sh is missing. Please add it to your dotfiles."
    exit 99
fi

export REGISTRY_SERVER=dev.registry.tanzu.vmware.com
export REGISTRY_REPO=app-live-view/test
export REGISTRY_USER=${TANZUNET_USER}
export REGISTRY_PASSWORD=${TANZUNET_PASSWORD}
export REGISTRY=${REGISTRY_SERVER}/${REGISTRY_REPO}
export DOMAIN=tanzu.ga  # Needs to be a domain that you controll and can create DNS records for.

workdir=$(pwd)

if kubectl get namespace tap-install > /dev/null 2>&1; then
    echo "Skipping tap installation (already installed)"
else
    echo "Installing tap into the cluster..."
    ./01-prereqs.sh
    ./02-tap-install-profile.sh
fi
./03-setup-dev-namespace.sh
./04-create-workloads.sh
#./03-alv-carvel.sh
#     # alternatively: 02-alv-tap.sh
#./04-pstar-from-source.sh
#./05-workloads.sh
# ./05-apps-direct-deployment.sh
#./99-alv-ingress.sh

#tanzu apps workload tail tanzu-java-web-app --since 10m --timestamp