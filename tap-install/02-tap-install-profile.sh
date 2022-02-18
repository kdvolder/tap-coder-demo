#!/bin/bash

set -euox pipefail

readonly TAP_REPO_VERSION=1.0.2-build.2

# https://docs-staging.vmware.com/en/Tanzu-Application-Platform/0.4/tap/GUID-install.html
# This script requires:
# - some env vars to be set prior to running. See file `sample-tap-install.sh` for an example
#   on how you might call this script.
# - kubectl logged in and targetting the cluster where you want to install TAP

kubectl create ns tap-install || echo "Namespace tap-install exists"

tanzu secret registry add tap-registry \
  --username "${TANZUNET_USER}" --password "${TANZUNET_PASSWORD}" \
  --server registry.tanzu.vmware.com \
  --export-to-all-namespaces --yes --namespace tap-install

tanzu package repository add tanzu-tap-repository \
  --url registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_REPO_VERSION} \
  --namespace tap-install

mkdir -p tmp
envsubst > tmp/tap-values.yaml << EOF
profile: light
# excluded_packages:
# - run.appliveview.tanzu.vmware.com
# - build.appliveview.tanzu.vmware.com
# - tap-gui.tanzu.vmware.com
ceip_policy_disclosed: true

buildservice:
  kp_default_repository: "${REGISTRY}"
  kp_default_repository_username: "${TANZUNET_USER}"
  kp_default_repository_password: "${TANZUNET_PASSWORD}"
  tanzunet_username: "${TANZUNET_USER}"
  tanzunet_password: "${TANZUNET_PASSWORD}"

cnrs:
  domain_name: ${DOMAIN}

supply_chain: basic
  
ootb_supply_chain_basic:
  registry:
    server: "${REGISTRY_SERVER}"
    repository: "${REGISTRY_REPO}"
  # The empty value below is a workaround for some bug in supply chain
  # Do not really understand it. But that's what they tell us to do.
  gitops:
    ssh_secret: ""

tap_gui:
  service_type: ClusterIP
  ingressEnabled: "true"
  ingressDomain: ${DOMAIN}
  app_config:
    app:
      baseUrl: http://tap-gui.${DOMAIN}
    backend:
      baseUrl: http://tap-gui.${DOMAIN}
      cors:
        origin: http://tap-gui.${DOMAIN}
    integrations:
      github: # Other integrations available see NOTE below
      - host: github.com
        token: ${GITHUB_TOKEN}

    catalog:
      rules:
        - allow: [Component, Domain, System, API, Group, User, Resource, Location]
      locations:
      - type: url
        target: https://github.com/kdvolder/tap-catalog/blob/main/catalog-info.yaml

metadata_store:
  app_service_type: LoadBalancer # (optional) Defaults to LoadBalancer

# This piece below was added by kdvolder to be able to use the 'baked in' 
# contour as ingress from the public internet.
contour:
  envoy:
    service:
      type: LoadBalancer
EOF

TAP_VERSION=$(tanzu package available list tap.tanzu.vmware.com --namespace tap-install | tail -n 1 | tr -s ' ' | cut -d" " -f3)
tanzu package install tap -p tap.tanzu.vmware.com -v ${TAP_VERSION} --values-file tmp/tap-values.yaml -n tap-install

#####################################################################################
# Set up 'default' as a developer namespace
# https://docs-staging.vmware.com/en/Tanzu-Application-Platform/0.4/tap/GUID-install-components.html#set-up-developer-namespaces-to-use-installed-packages-42

tanzu secret registry add registry-credentials \
  --username ${REGISTRY_USER} \
  --password ${REGISTRY_PASSWORD} \
  --server ${REGISTRY_SERVER} \
  --export-to-all-namespaces --yes \
  --namespace default
# export-to-all-namespaces option should not be needed but is a bug workaround

########################################################################################
### Extra stuff added by kdvolder

# Some tweaks to knative config.
envsubst > tmp/knative-config.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-autoscaler
  namespace: knative-serving
data:
  enable-scale-to-zero: "false"
EOF
kubectl apply -f tmp/knative-config.yaml