# web-go-k8

Single Go prototype application utilizing Docker, Kubernetes, and Helm to Deploy to a Kubernetes Cluster.


NOTES:
- Forked from https://github.com/nwillc/webgo
- Forked for additional experimentation/configuration/personal learning.

 REQUIREMENTS:
 - [Docker](https://docs.docker.com/get-docker/) Installed (Linux Containers)
     - Recommended: [Docker Desktop](https://www.docker.com/products/docker-desktop) Installed, [Docker Desktop Kubernetes Enabled](https://docs.docker.com/desktop/kubernetes/#enable-kubernetes)
 - [Go Lang](https://golang.org/doc/install) Installed
 - [Helm](https://helm.sh/docs/intro/install/) Installed
 - [Kubernetes (K8)](https://kubernetes.io/releases/download/) Installed (kubectl)
 - (Optional) [DockerHub](https://hub.docker.com/****) Account/Login

## Running Application

## Optional Steps
1. Push Docker Image to DockerHub (or other Container Registry)
   ```bash 
   docker login -u {DockerID}
   docker build -t {DockerID}/webgo .
   docker push {DockerID}/webgo
   ```
2. Modify `charts/webgo/values.yaml`
   ```yaml
   image:
    repository: {DockerID}/webgo # UPDATE LINE TO DOCKERID
    ...
   ```
3. (**IF NOT USING [Docker Desktop Kubernetes](https://docs.docker.com/desktop/kubernetes/#enable-kubernetes)**) Modify `charts/webgo/values.yaml` 
   ```yaml
   ingress:
    ...
    hosts:
      - host: {HOSTNAME} # IF NOT USING Docker Desktop K8 Cluster
    ...
   ```
   - Kubernetes has a [Ingress minikube Guide ](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#create-an-ingress-resource) for example
     - NOTE: If using Ingress minikube, remember to add the following:
     ```
     minikube addons enable ingress
     ```

## Core Steps
1. Connect to Desired K8 Cluster ([Minikube guide](https://minikube.sigs.k8s.io/docs/start/), [Google Cloud GKE guide](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl), [Docker Desktop Kubernetes guide](https://docs.docker.com/desktop/kubernetes/#enable-kubernetes) )
   ```bash
   kubectl config get-contexts
   kubectl config use-context {desiredContext}
   ```
2. Deploy to K8 Cluster with Helm (shorcut [commit](https://github.com/helm/helm/commit/d6eab468762e4020b49d1852de5b2df53f194eb5#diff-8f7c1d7e2cfeb70c465f36198e54a053fb517420d8647ffaf72a15e5525eb596) waiting for release)
   ```bash
   helm dependency update ./charts/webgo
   helm upgrade --values config.yaml -i webgo ./charts/webgo -n local-dev --create-namespace
   ```
3. Run Application (May take a few seconds/minutes to startup)
   ```bash
   curl http://{HOSTNAME}
   ```

## Exiting/Cleaning up Application
1. Uninstall the webgo helm release
   ```
   helm uninstall -n local-dev webgo
   ```
2. Delete `local-dev` namespace
   ```bash
   kubectl delete namespace local-dev
   ```
## About Ingress Hostname Resolution
- Docker Desktop automatically adds a host file entry 
  ```
  127.0.0.1 kubernetes.docker.internal
  ```
- `127.0.0.1 (localhost)` is the external ip for the ingress controller (ingress redirects requests from kubernetes.docker.internal to localhost)
  - To find out the external ip (should say `localhost`)
    ```
    kubectl get services -n local-dev
    ```
    - This makes it so requests to kubernetes.docker.internal resolve to the Ingress Controller's Public/External IP
    - **BUG:** See https://github.com/docker/for-mac/issues/4903 if External IP says `pending` (though it should be 127.0.0.1 for local PC regardless)

## Resolving DNS to Reserved IPs (Ingress Controller)
  - [Google has a guide around configuring domain names w/ static IP address](https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip) walking through the basic concepts.
  - Here is a [GoDaddy article outlining why you need to modify the etc/hosts for local development](https://www.godaddy.com/help/preview-your-website-using-hosts-files-3354)
  - [Stack Overflow Related Question](https://stackoverflow.com/questions/55087898/kube-ingress-with-hostname-how-to-know-ip-to-forward-domain-name)

  ## Helpful Tools/Resources
  - [kubectx](https://github.com/ahmetb/kubectx) - Power Tools for kubectl
  - [kube-ps1](https://github.com/jonmosco/kube-ps1) - Kubernetes prompt for bash & zsh
