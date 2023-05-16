# Helm Charts Packaging and Distribution

This repository repesents a guideline on how should we approach Helm Chart packaging and distribution of our charts to our users.
Complete strategy can be found in [this](https://www.notion.so/rasa/Helm-Distribution-Strategy-a5bbd0c3722e44ee8baae16b08891175) document.

## Overview
- We are using Google Artifact Registry as Helm repository.
- We are storying Helm Charts the same way we would approach storing Docker images.
- We are using OCI to push or pull our charts.
- We are building strong sense of versioning and safe distribution of our charts using short-lived Access Tokens or Service Account keys.
- We are testing and linting our charts before the release following [Red Hat Community of Practice](https://redhat-cop.github.io/ci/linting-testing-helm-charts.html) guideliness.
- We are introducting security scans of our Helm charts using Snyk.
- We are generating Helm docs in pre-commit format.
- We have the ability to enforce `Chart.yaml` schema configuration.
- We have the ability to enforce YAML style standards across the projects.
- We have the ability to centralize our charts in a form of a monorepo.

# The Studio Library for Kubernetes

Rasa Studio, ready to launch on Kubernetes using [Kubernetes Helm](https://github.com/helm/helm).

## TL;DR

```bash
helm install my-release oci://registry-1.docker.io/helm-charts/<chart>
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

- Install a chart: `helm install my-release oci://registry-1.docker.io/helm-charts/<chart>`
- Upgrade your application: `helm upgrade my-release oci://registry-1.docker.io/helm-charts/<chart>`
