#!/bin/bash
set euo pipefail
kapp -y delete -n ${CODER_WORKSPACE_NAME} -a workloads
kubectl delete ns ${CODER_WORKSPACE_NAME}