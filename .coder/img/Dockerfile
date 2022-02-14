# See our guides for writing custom images:
# https://coder.com/docs/guides/customization

FROM codercom/enterprise-base:ubuntu

# Install programs

# tanzu cli
COPY --chown=1000:1000 tanzu /home/coder/tanzu
RUN pushd /home/coder/tanzu && \
    ./install-tanzu-cli.sh && \
    popd

# aws eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    sudo mv /tmp/eksctl /usr/local/bin

# aws cli
RUN pushd /tmp && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm -fr aws && \
    popd

# kubectl
RUN pushd /tmp && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    popd

# apt packages
RUN sudo apt-get update && \
    sudo apt-get install -y jq gettext-base
