#!/bin/bash
set -euo pipefail
kapp -y deploy -n default -a workloads -f workloads.yaml