#/bin/bash
cd ~
pushd tanzu
cat tanzu-cli.tar.gz.part* | tar zxv
rm -fr tanzu-cli.tar.gz.part*
popd
pushd tanzu/cli/core
    tanzu_binary=$(find  -name tanzu-core-linux_amd64)
    sudo install $tanzu_binary /usr/local/bin/tanzu
popd
export TANZU_CLI_NO_INIT=true
# Beta 4 hack? https://docs-staging.vmware.com/en/Tanzu-Application-Platform/0.4/tap/GUID-install-general.html#cli-plugin-clean-install
tanzu config set features.global.context-aware-cli-for-plugins false
pushd tanzu
    tanzu plugin install --local cli all
popd
