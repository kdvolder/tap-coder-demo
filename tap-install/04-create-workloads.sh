#!/bin/bash
set -euo pipefail
kapp -y deploy -n ${CODER_WORKSPACE_NAME} -a workloads -f workloads.yaml