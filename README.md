# TAP Coder Demo

This is a coder workspace template that does the following when instantiated:

- Derives from a base docker image that has useful cli tools pre-installed:
   - tanzu cli
   - kubectl
   - kp (kpack cli)
   - eksctl (amazon cli to interact with or create EKS clusters)
   - aws cli
- Creates an EKS cluster with a name ${workspace-name}-cluster.
- Installs the TAP 'light' profile onto the cluster.
- Configures the 'default' namespace as a 'developer' namespace (i.e. for use with supply-chain resources and knative).
- configures tanzu cli, and kubectl cli to target the cluster.
- pre-install vscode plugins:
   - Pivotal spring-boot-tools
   - Redhat Java tools
   - ms-vscode-kubernetes tools  
- Configure's git for pushing / pulling to github
- Clone's `kdvolder/spring-petclinic` github repo. Note: If you want be able to edit and push yourself, you will 
   have to modify this template and personalize so as to to clone a repo to which you personally have push access)
- Creates a workload that builds and deploys petclinic the cloned.

Once the workspace is created, you can open the 'Code Web' IDE and start editing. This gives you access to:

- the code for the template itself. This includes script code for setting up TAP. This code can be edited to change
  details of the cluster and how it is configured (e.g. maybe you want to install a different version of TAP
  into your cluster; or maybe you want to change some 'tap-values').
- the code for petclinic (so you can edit your app)

## Contents of this repo:

* Coder workspace template - `.coder/coder.yaml`
* Custom image for Coder - `.coder/img`
* GitHub Actions CI for building the custom image - `.github/workflows/build-image.yaml`
* Automation of TAP cluster creation and installation - `tap-instal/`.
* Entry point for workspace setup and personalization - `personalize.sh`

## Set up

1. Create a fork of this project to create your own.
2. Find all references to username 'kdvolder' in this repo and replace it with your own.
3. Add [secrets](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository) to the repository with your [Docker Hub](https://hub.docker.com/) account details:

        DOCKERHUB_USERNAME (your username for Docker Hub)
        DOCKERHUB_TOKEN (your password or token)

4. Push to `main` (to build the docker image).
5. Add the image into Coder. (repository: your value for `username/projectname` tag: `latest`)
6. If you haven't already, enable Workspace Templates under Manage -> Admin -> Templates
7. Inspect `tap-instal/install-tap.sh` and make changes as needed,
8. Setup a private 'username/tap-coder-dotfiles' repo as described in the next section.

## Setup tap-coder-dotfiles with secrets

The various scripts in this repo used to automate TAP-cluster creation/configuration require your credentials to
access AWS and tanzunet. This information has been deliberately omitted from this public repo. However, it needs to accessible somehow to the scripts when they execute. Coder's support for [dotfiles](https://coder.com/docs/coder/latest/workspaces/personalization#dotfiles-repo) is used for this.

**The dotfiles repo should be a private repo** since it will contain secret information such api tokens that 
you should never share publically. Coder will be able to clone the private repo on your behalf and use the information provided you configure it correctly. See [these](https://coder.com/docs/coder/latest/getting-started/developers) instructions.

The 'your-username/tap-coder-dotfiles` repo should contain the following files with secrets:

**.cg_secrets.sh**:
```
# Cloudgate access: obtained via https://console.cloudgate.vmware.com/ui/#/settings/clients
export CG_CLIENT_ID=...fill in...
export CG_CLIENT_SECRET=...fill in...
```

**.tanzu-secrets.sh**:
```
# Various secret values that are required by tanzu-install (but cannot be included in a public repo)
export GITHUB_TOKEN=...fill in...
export TANZUNET_USER=...fill in...
export TANZUNET_PASSWORD=...fill in...
```

## Create your first workspace

Now you are ready to create a new workspace from this template in the Ui.

Note that creation of EKS cluster and installing TAP is a lenghty process and may take 15 to 20 minutes.
This happens the first time you create/build a workspace. When you subsequently rebuild or restart the workspace
EKS cluster creation will be skipped. The scripts to install TAP will be executed each time the workspace
restarts or is rebuilt, however, because of kapp controller reconciling magic, the scripts will execute 
much faster when TAP is already installed. However, you can make use of this to modify tyour tap cluster
setup by editing the scripts and rebuilding the workspace. Reconciliation should take care of brining the
cluster in synch with your changes, but without needing to perform a full install each time.

## Confguring the ingress domain

Before you can access your workloads via their automatically created ingress... there is one final manual step
you need to do. You need to point a wildcard DNS entry at the envoy/contour loadbalancer.

Find out where to point your dns entry using the following command:

```
$ kubectl get service -n tanzu-system-ingress
NAME      TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)                      AGE
contour   ClusterIP      10.100.189.137   <none>                                                                   8001/TCP                     26h
envoy     LoadBalancer   10.100.209.125   abeaafdabf3aa4491a882e983f159416-295984139.us-west-1.elb.amazonaws.com   80:31954/TCP,443:32704/TCP   26h
```

Take note of the AWS loadbalancer in the above output. That is where your wildcard domain should point.

Note: You can skip this step, everything will work more or less as expected, but you will not be able
to access you workloads from their public URLs.