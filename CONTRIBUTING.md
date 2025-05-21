# Contributing to Rasa Helm Charts

## Getting Help

If you have questions about Rasa Helm Charts, you can:

- Ask a question in our [GitHub Issues](https://github.com/RasaHQ/rasa-helm-charts/issues)
- Please use the label `question`

## Development

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


## Code of Conduct

Please be respectful and considerate of others when contributing to this project. We expect all contributors to follow our [Code of Conduct](CODE_OF_CONDUCT.md). 
