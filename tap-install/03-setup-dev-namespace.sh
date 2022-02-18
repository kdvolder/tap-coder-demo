#!/bin/bash
set -euo pipefail
NAMESPACE=${CODER_WORKSPACE_NAME}
kubectl create ns $NAMESPACE || echo "Namespace ${NAMESPACE} exists"
kubectl apply -n ${NAMESPACE} -f dev-namespace-knative-enablement.yaml
kubectl config set-context --current --namespace=$NAMESPACE