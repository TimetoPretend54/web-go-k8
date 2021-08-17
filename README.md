# web-go-k8

Single Go prototype application utilizing Docker, Kubernetes, and Helm to Deploy to a Kubernetes Cluster.


NOTES:
- Thank you to https://github.com/nwillc for the original webgo project.
- Forked from https://github.com/nwillc/webgo
- Forked for additional experimentation/configuration/personal learning.

# Running Application
 REQUIREMENTS:
 - [Docker Desktop](https://www.docker.com/products/docker-desktop) Installed (Linux Containers)
   - Recommended: [Docker Desktop Kubernetes Enabled](https://docs.docker.com/desktop/kubernetes/#enable-kubernetes)
 - [Go Lang](https://golang.org/doc/install) Installed
 - [Helm](https://helm.sh/docs/intro/install/) Installed
 - [Kubernetes (K8)](https://kubernetes.io/releases/download/) Installed (kubectl)
 - [DockerHub](https://hub.docker.com/****) Account/Login

1. **(OPTIONAL)** Push Docker Image to DockerHub
   ```bash 
   docker login -u {DockerID}
   docker build -t {DockerID}/webgo .
   docker push {DockerID}/webgo
   ```
2. **(OPTIONAL)** Modify `values.yaml`
   ```yaml
   image:
    repository: {DockerID}/webgo # UPDATE LINE TO DOCKERID
    ...
   ```

   (**IF NOT USING Docker Desktop Kubernetes**) Also modify 
   ```yaml
   ingress:
    ...
    hosts:
      - host: {ENTER HOSTNAME HERE} # IF NOT USING Docker Desktop K8 Cluster
    ...
   ```
   - Kubernetes has a [Ingress minikube Guide ](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#create-an-ingress-resource) for example
3. Deploy to K8 Cluster with Helm
   
   **Dry Run**
   ```bash
   helm upgrade --values config.yaml -i webgo --dry-run --debug ./charts/webgo -n local-dev --create-namespace
   ```
   **Deployment** (This will be a liner once helm adds [this commit](https://github.com/helm/helm/commit/d6eab468762e4020b49d1852de5b2df53f194eb5#diff-8f7c1d7e2cfeb70c465f36198e54a053fb517420d8647ffaf72a15e5525eb596) to a release)
   ```bash
   helm dependency update ./charts/webgo
   helm upgrade --values config.yaml -i webgo ./charts/webgo -n local-dev --create-namespace
   ```
4. Change to `local-dev` namespace (Helm Chart created resources under this)
   ```bash
   kubectl config set-context --current --namespace=local-dev
   ```
5. Run Application
   
   **Check that it worked**
   ```bash
   helm ls
   kubectl get pods
   ```
   **Run/Access Application** (may take a few seconds/minutes to startup)
   ```bash
   curl http://kubernetes.docker.internal
   ```

# Exiting/Cleaning up Application
1. Find/validate the webgo helm release
   ```bash
   helm ls
   ```
2. Uninstall the webgo helm release
   ```
   helm uninstall -n local-dev webgo
   ```
3. **(Optional)** Delete `local-dev` namespace
   ```bash
   kubectl delete namespace local-dev
   ```
4. **(Optional)** Set namespace back to `default` (or whatever you prefer)
   ```bash
   kubectl config set-context --current --namespace=default
   ```

# About Ingress Hostname Resolution
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