# Rasa Helm Chart Library for Kubernetes

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)

Rasa Studio and Rasa Pro, ready to launch on Kubernetes using [Kubernetes Helm](https://github.com/helm/helm).

Chart documentation per chart:

- [Rasa Studio](https://helm.rasa.com/charts/studio/)
- [Rasa Pro](https://helm.rasa.com/charts/rasa/)
- [Operator Kits](https://helm.rasa.com/charts/op-kits/)

## License

By installing and using this software, you agree to be bound by the terms and conditions of the End-User License Agreement (EULA) available on [rasa.com](https://rasa.com/eula). Please review the EULA carefully before proceeding.

## TL;DR

You can install charts from either the GitHub Helm repository or the OCI registry.

```bash
# From GitHub Helm repository
helm repo add rasa https://helm.rasa.com/charts && helm repo update
helm install <your release name> rasa/studio
helm install <your release name> rasa/rasa

# From OCI registry
helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio
helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa
```

## Before you begin

### Prerequisites

- Kubernetes 1.24+
- Helm 3.0.0+

### Setup a Kubernetes Cluster

For setting up Kubernetes on other cloud platforms or bare-metal servers refer to the Kubernetes [getting started guide](https://kubernetes.io/docs/getting-started-guides/).

### Install Helm

Helm is a tool for managing Kubernetes charts. Charts are packages of pre-configured Kubernetes resources.

To install Helm, refer to the [Helm install guide](https://github.com/helm/helm#install) and ensure that the `helm` binary is in the `PATH` of your shell.

### Using Helm

Once Helm is installed, you can deploy Rasa charts into a Kubernetes cluster.

Please refer to the [Quick Start guide](https://helm.sh/docs/intro/quickstart/) for a quick start, or the [Using Helm Guide](https://helm.sh/docs/intro/using_helm/) for detailed instructions.

#### Install from GitHub Helm repository

```bash
helm repo add rasa https://helm.rasa.com/charts
helm repo update

# Latest version
helm install <your release name> rasa/studio
helm install <your release name> rasa/rasa

# Specific version
helm install <your release name> rasa/studio --version <desired version>
helm install <your release name> rasa/rasa --version <desired version>
```

#### Install from OCI registry

```bash
# Latest version
helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio
helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa

# Specific version
helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version <desired version>
helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version <desired version>
```

## Contributing

We'd love to have you contribute! Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.

## Other Rasa Products

You can find our older Helm charts for other Rasa products here:

- [Rasa Open Source](https://github.com/RasaHQ/helm-charts/tree/main/charts/rasa)
- [Rasa Action Server](https://github.com/RasaHQ/helm-charts/tree/main/charts/rasa-action-server)
- [Rasa X/Enterprise](https://github.com/RasaHQ/rasa-x-helm)
- [Duckling](https://github.com/RasaHQ/helm-charts/tree/main/charts/duckling)
