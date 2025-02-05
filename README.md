# k8s-local-airflow
A local setup for running Airflow on K8s

## Requirements
- [Helm](https://helm.sh/docs/intro/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [docker-desktop](https://docs.docker.com/desktop/)


__NOTE__: instructions are for `docker-desktop`. If you have `minikube` installed and running, make sure you're using `docker-desktop` context by running:
```bash
make check-context
```
***
## Setup
Create a `values.yaml` file:
```bash
cp example-values.yaml values.yaml
```
Then update the `hostPath` values in `values.yaml` to match your local settings.

***
## Install
Ensure `docker-desktop` is up and running, then install Airflow using our Helm chart and configurations:
```bash
make install
```

***
### Access the Web UI
To access the web UI, you need to forward traffic from the webserver container to the host by running:
```bash
make port-forward
```
You will be able to access the UI from [`localhost:8080`](http://localhost:8080).

The username and password is `admin`.

***
## Clean
To clean up the setup, i.e., shutting down the containers, deleting the pods, the namespace and other resources, run:
```bash
make clean
```

***