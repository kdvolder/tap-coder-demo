#!/bin/bash
set -euo pipefail

region=us-west-1
cluster_name=shared-coder-cluster

aws configure set default.region $region

if eksctl get cluster --name "$cluster_name" --region $region ; then
    echo "EKS Cluster exists, skip creation"
else
    eksctl create cluster \
        --name "$cluster_name" \
        --region $region \
        --node-type m5.xlarge \
        --nodes 3
fi

aws eks update-kubeconfig --name "$cluster_name" --region "$region" --kubeconfig ~/.kube/config-eks
mv ~/.kube/config-eks ~/.kube/config
kubectl get namespaces
