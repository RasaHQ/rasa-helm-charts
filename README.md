# Rasa Helm Chart Library for Kubernetes

Rasa Studio and Rasa Pro, ready to launch on Kubernetes using [Kubernetes Helm](https://github.com/helm/helm).

Chart usage can be found:

- [Rasa Studio](https://github.com/RasaHQ/rasa-helm-charts/blob/main/charts/studio/README.md)
- [Rasa Pro](https://github.com/RasaHQ/rasa-helm-charts/blob/main/charts/rasa/README.md)

## License

`By installing and using this software, you agree to be bound by the terms and conditions of the End-User License Agreement (EULA) available on [rasa.com](https://rasa.com/eula). Please review the EULA carefully before proceeding.`

## TL;DR

```bash
helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio
helm install <your release name> oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa
```

## Before you begin

### Prerequisites

- Kubernetes 1.19+
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

## Development Internals

### Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- [pre-commit](https://pre-commit.com/)
- [helm-docs](https://github.com/norwoodj/helm-docs)

> **Please install and use `pre-commit-hook` before creating the PR so we can have all our README files up to date with the chart changes.**

Before you can run hooks, you need to have the pre-commit package manager installed.

Using pip:

```bash
pip install pre-commit
```

Using homebrew:

```bash
brew install pre-commit
```

Install the git hook scripts
```bash
pre-commit install
```
now `pre-commit` will run automatically on `git commit`!

Make sure to always check if `README.md` is valid and reflects your changes properly. Also, make sure to leave comments in `values.yaml` in form:

```yaml
# -- This is a description showed in README.md
enabled: false
```

### Development

This repository automatically release a new version of the Helm chart once new changes are merged. The only required steps are:

1. Make the changes to the chart
2. Run `helm lint --strict charts/<CHART>`
3. Increase the chart version in `charts/<CHART>/Chart.yaml`
4. Run `pre-commit run --all-files` before pushing to the remote. This will auto update the Readme files. Make sure to commit them back.

## How To Contribute

Contributions, issues and feature requests are welcome!

For major changes, please open an [issue](https://github.com/RasaHQ/rasa-helm-charts/issues), or:

1. Create a branch: `git checkout -b <branch_name>`.
2. Install [pre-commit](https://pre-commit.com/).
3. Make your changes and commit them: `git commit -m "<commit_message>"`
4. Push to the original branch: `git push origin <branch_name>`
5. Create the pull request.

Alternatively see the GitHub documentation on [creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).
