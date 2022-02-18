#!/bin/bash
set -euo pipefail
NAMESPACE=${CODER_WORKSPACE_NAME}

#####################################################################################
# Set up $NAMESPACE as a developer namespace
# https://docs-staging.vmware.com/en/Tanzu-Application-Platform/0.4/tap/GUID-install-components.html#set-up-developer-namespaces-to-use-installed-packages-42

kubectl create ns $NAMESPACE || echo "Namespace ${NAMESPACE} exists"

tanzu secret registry add registry-credentials \
  --username ${REGISTRY_USER} \
  --password ${REGISTRY_PASSWORD} \
  --server ${REGISTRY_SERVER} \
  --export-to-all-namespaces --yes \
  --namespace $NAMESPACE
# export-to-all-namespaces option should not be needed but is a bug workaround

kubectl apply -n ${NAMESPACE} -f dev-namespace-knative-enablement.yaml
kubectl config set-context --current --namespace=$NAMESPACE