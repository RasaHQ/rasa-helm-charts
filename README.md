# Rasa Helm Chart Library for Kubernetes

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)

Rasa Studio and Rasa Pro, ready to launch on Kubernetes using [Kubernetes Helm](https://github.com/helm/helm).

Chart usage can be found:

- [Rasa Studio](https://helm.rasa.com/charts/studio/)
- [Rasa Pro](https://helm.rasa.com/charts/rasa/)
- [Operator Kits](https://helm.rasa.com/charts/op-kits/)

## License

By installing and using this software, you agree to be bound by the terms and conditions of the End-User License Agreement (EULA) available on [rasa.com](https://rasa.com/eula). Please review the EULA carefully before proceeding.

## TL;DR

```bash
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

Once you have installed the Helm client, you can deploy a Studio Helm Chart into a Kubernetes cluster.

Please refer to the [Quick Start guide](https://helm.sh/docs/intro/quickstart/) if you wish to get running in just a few commands, otherwise the [Using Helm Guide](https://helm.sh/docs/intro/using_helm/) provides detailed instructions on how to use the Helm client to manage packages on your Kubernetes cluster.

#### Useful Helm Client Commands:

Rasa Studio:

```yaml
- Install a chart: helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio
- Upgrade your application: helm upgrade <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio
- Install specific version: helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version <desired version>
- Delete the release: helm delete <your release name>
```

Rasa Pro:

```yaml
- Install a chart: helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa
- Upgrade your application: helm upgrade <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa
- Install specific version: helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version <desired version>
- Delete the release: helm delete <your release name>
```

## Contributing

We'd love to have you contribute! Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.

## Other Rasa Products

You can find our older Helm charts for other Rasa products here:

- [Rasa Open Source](https://github.com/RasaHQ/helm-charts/tree/main/charts/rasa)
- [Rasa Action Server](https://github.com/RasaHQ/helm-charts/tree/main/charts/rasa-action-server)
- [Rasa X/Enterprise](https://github.com/RasaHQ/rasa-x-helm)
- [Duckling](https://github.com/RasaHQ/helm-charts/tree/main/charts/duckling)
