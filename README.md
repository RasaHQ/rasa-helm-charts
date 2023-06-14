# The Studio Library for Kubernetes

Rasa Studio, ready to launch on Kubernetes using [Kubernetes Helm](https://github.com/helm/helm).

Chart usage can be found [here](https://github.com/RasaHQ/helm-packaging/blob/main/charts/studio/README.md).

## TL;DR

```bash
helm install <your release name> oci://registry-1.docker.io/helm-charts/studio
```

## Before you begin

### Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

### Setup a Kubernetes Cluster

For setting up Kubernetes on other cloud platforms or bare-metal servers refer to the Kubernetes [getting started guide](https://kubernetes.io/docs/getting-started-guides/).

### Install Helm

Helm is a tool for managing Kubernetes charts. Charts are packages of pre-configured Kubernetes resources.

To install Helm, refer to the [Helm install guide](https://github.com/helm/helm#install) and ensure that the `helm` binary is in the `PATH` of your shell.

### Using Helm

Once you have installed the Helm client, you can deploy a Studio Helm Chart into a Kubernetes cluster.

Please refer to the [Quick Start guide](https://helm.sh/docs/intro/quickstart/) if you wish to get running in just a few commands, otherwise the [Using Helm Guide](https://helm.sh/docs/intro/using_helm/) provides detailed instructions on how to use the Helm client to manage packages on your Kubernetes cluster.

Useful Helm Client Commands:

- Install a chart: `helm install <your release name> oci://registry-1.docker.io/helm-charts/studio`
- Upgrade your application: `helm upgrade <your release name> oci://registry-1.docker.io/helm-charts/studio`
- Install specific version: `helm install <your release name> oci://registry-1.docker.io/helm-charts/studio --version <desired version>`


## Development Internals

### Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- [pre-commit](https://pre-commit.com/)
- [helm-docs](https://github.com/norwoodj/helm-docs)

Make sure to always check if `README.md` is valid and reflects your changes properly. Also, make sure to leave comments in `values.yaml` in form:

```yaml
    # -- This is a description showed in README.md
    enabled: false
```

### Development

This repository automatically release a new version of the Helm chart once new changes are merged. The only required steps are:

1. Make the changes to the chart
2. Run `helm lint --strict charts/studio`
3. Increase the chart version in `charts/studio/Chart.yaml`
## How To Contribute

Contributions, issues and feature requests are welcome!

For major changes, please open an [issue](https://github.com/RasaHQ/helm-packaging/issues), or:

  1. Create a branch: `git checkout -b <branch_name>`.
  2. Make your changes and commit them: `git commit -m "<commit_message>"`
  3. Push to the original branch: `git push origin <branch_name>`
  4. Create the pull request.

Alternatively see the GitHub documentation on [creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).
