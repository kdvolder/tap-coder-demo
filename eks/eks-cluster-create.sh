#!/bin/bash
set -euo pipefail

#source ./setup-aws-env-vars.sh

region=us-west-1
cluster_name=tap-coder-demo-1

if eksctl get cluster --name "$cluster_name" --region $region ; then
    echo "EKS Cluster exists, skip creation"
else
    eksctl create cluster \
        --name "$cluster_name" \
        --region $region \
        --node-type m5.xlarge \
        --nodes 3
fi

# Do not put these `eksctl create` arguments: (aws docs do put them but not working with vmware cloudgate)
#--ssh-access \
#--ssh-public-key key

aws eks update-kubeconfig --name "$cluster_name" --region us-west-1 --kubeconfig ~/.kube/config-eks
mv ~/.kube/config-eks ~/.kube/config
kubectl get namespaces

