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
