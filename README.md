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

A valid license key is required before installing. Refer to the documentation for each chart for setup instructions: [Rasa Pro](https://helm.rasa.com/charts/rasa/) · [Rasa Studio](https://helm.rasa.com/charts/studio/).

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

- Kubernetes 1.30+
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

## Guided deployment with Claude Code

If you use [Claude Code](https://www.claude.com/product/claude-code), this repository ships a plugin — **`rasa-helm-deploy`** — that walks you through deploying the charts step by step. It is aimed at users who want a working deployment with minimal Helm or Rasa knowledge.

The assistant will:

- Ask only for what a deployment actually needs (license, ingress host, datastore connection, …) and apply sensible defaults for the rest.
- Auto-detect your ingress controller (nginx / Traefik / AWS ALB) and generate matching annotations.
- Generate the required Kubernetes `Secret` — either as a ready-to-run `kubectl create secret` command (from values you provide) or as a placeholder manifest with instructions (if you'd rather not share values). Chart-required secrets such as the Rasa Pro `authToken` and `jwtSecret` are generated for you.
- Generate a schema-valid `values.yaml` (or equivalent `--set` flags), then validate it with `helm lint --strict` and a `helm template` render before handing you a version-pinned `helm install` command.
- Optionally provision PostgreSQL / Kafka in-cluster via the [op-kits](charts/op-kits/) chart and wire the connection details into Studio for you.

### Install the plugin

In Claude Code, add this repository as a plugin marketplace and install the plugin:

```text
/plugin marketplace add RasaHQ/rasa-helm-charts
/plugin install rasa-helm-deploy@rasa-helm-charts
```

### Use it

Invoke the command with the chart you want to deploy — `rasa` for [`charts/rasa/`](charts/rasa/) (Rasa Pro) or `studio` for [`charts/studio/`](charts/studio/) (Rasa Studio):

```text
/rasa-helm configure rasa
/rasa-helm configure studio
```

Use `configure` to generate the secret and values files only, or `install` / `upgrade <release>` to also produce (and, after you confirm, run) the Helm command. The assistant never runs a mutating command without your explicit confirmation, and always tells you which cluster context and namespace it targets first.

## Contributing

We'd love to have you contribute! Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.

## Other Rasa Products

You can find our older Helm charts for other Rasa products here:

- [Rasa Open Source](https://github.com/RasaHQ/helm-charts/tree/main/charts/rasa)
- [Rasa Action Server](https://github.com/RasaHQ/helm-charts/tree/main/charts/rasa-action-server)
- [Rasa X/Enterprise](https://github.com/RasaHQ/rasa-x-helm)
- [Duckling](https://github.com/RasaHQ/helm-charts/tree/main/charts/duckling)
