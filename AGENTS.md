# AGENTS.md

A guide for AI coding agents working on Rasa Helm Charts.

## Project Overview

This repository contains Helm charts for deploying Rasa products on Kubernetes:
- **Rasa Studio** (`charts/studio/`) — chart 3.x: unified `app` Deployment (API + web client, Better Auth), event ingestion via `eventIngestion.mode` (`colocated` | `separate` | `disabled`), optional Rasa Pro OCI subchart (`rasa.enabled`)
- **Rasa Pro** (`charts/rasa/`) — Rasa Pro server, action-server, duckling, rasa-pro-services
- **Operator Kits** (`charts/op-kits/`) — CR wrappers for PostgreSQL (CloudNativePG), Kafka (Strimzi), and Valkey; operators must be pre-installed

For user-facing documentation, see [README.md](README.md). For contribution guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md). For denser agent architecture notes (Helm 4, CI, Studio helpers), see [CLAUDE.md](CLAUDE.md).

## Prerequisites

- Kubernetes 1.30+
- Helm 3.2.0+ (Studio chart documents Helm 3.8.0+)
- Python 3.11.2 (for pre-commit hooks)
- [pre-commit](https://pre-commit.com/) tool
- [helm-docs](https://github.com/norwoodj/helm-docs) tool

## Setup Commands

### Install pre-commit

```bash
# Using pip
pip install pre-commit

# Using homebrew
brew install pre-commit
```

### Install pre-commit hooks

```bash
pre-commit install
```

This will run hooks automatically on `git commit`.

### Build chart dependencies

```bash
# Build dependencies for a specific chart
helm dependency build ./charts/studio
helm dependency build ./charts/rasa
helm dependency build ./charts/op-kits

# Or build all charts
for chart in studio rasa op-kits; do
  helm dependency build ./charts/$chart
done
```

## Build and Test Commands

### Lint a specific chart

```bash
helm lint --strict charts/<CHART>
```

Replace `<CHART>` with `studio`, `rasa`, or `op-kits`.

### Run chart-testing lint

```bash
ct lint --config ct.yaml
```

This uses the chart-testing tool configured in `ct.yaml` to lint only changed charts.

### List changed charts

```bash
ct list-changed --config ct.yaml
```

### Generate Helm templates

```bash
# Pass --kube-version so output matches CI (Snyk uses 1.29.0)
helm template ./charts/<CHART> --output-dir ./output --kube-version 1.29.0
```

Useful for debugging and security scanning.

### Run pre-commit on all files

```bash
pre-commit run --all-files
```

This will:
- Fix end-of-file issues
- Update README.md files from templates using helm-docs

### Update README files only

```bash
pre-commit run helm-docs --all-files
```

## Code Style Guidelines

### YAML Formatting

Follow the rules defined in `lintconf.yaml`:

- **No document start**: YAML files should NOT start with `---`
- **Indentation**: Use consistent spaces (not tabs)
- **Line length**: Disabled - lines can be any length
- **Line endings**: Unix-style (`\n`)
- **Trailing spaces**: Enabled - trailing spaces are allowed
- **Empty lines**: Maximum 2 consecutive empty lines, none at start/end of file
- **Comments**: Require starting space, minimum 2 spaces from content

### Values.yaml Comment Format

Use this format for comments in `values.yaml` files:

```yaml
# -- This is a description shown in README.md
enabled: false
```

The `# --` prefix is used by helm-docs to generate README.md documentation.

### Values Schema (`values.schema.json`)

`charts/studio/` and `charts/rasa/` ship `values.schema.json` (op-kits has none). Update the schema when adding values. Schemas use draft-07 with `#/definitions/...` refs (not `$defs`). Defaults must satisfy the schema — `helm lint --strict` validates them.

### Chart Version Management

- **Always increment** the `version` field in `charts/<CHART>/Chart.yaml` when making changes
- Use semantic versioning format (e.g., `1.3.2`, `2.2.2`)
- On `release/*` branches, use `-rc.X` suffixes (see Version Management below)
- CI **blocks** `-rc` versions from merging to `main`

### README Generation

- Each chart has a `README.md.gotmpl` template file
- README.md files are auto-generated from `README.md.gotmpl` and `values.yaml` comments
- Always commit generated README.md files after running pre-commit
- Never manually edit `README.md` — edit `README.md.gotmpl` and `values.yaml` `# --` comments

## Chart Structure Conventions

Each chart follows this structure:

```
charts/<CHART>/
├── Chart.yaml          # Chart metadata and dependencies
├── values.yaml         # Default values with helm-docs comments
├── values.schema.json  # Input validation (studio, rasa only)
├── README.md.gotmpl    # Template for auto-generated README
├── README.md           # Auto-generated documentation
├── templates/          # Kubernetes resource templates
│   ├── _helpers.tpl    # Helper template functions (rasa: templates/helpers/)
│   ├── tests/          # Test templates
│   └── network-policy/ # Network policy templates
└── secrets.yaml        # Secrets template (some charts)
```

Studio nests workloads under `templates/studio/{app,event-ingestion}/` plus `templates/studio/_env.tpl`. Chart 3.0 notes:
- `backend` → `app`; no separate web-client Deployment (`app.webClient` ConfigMap mount only)
- `eventIngestion.enabled` removed — use `eventIngestion.mode`
- Auth: Better Auth on the app

### Chart Dependencies

- Dependencies are declared in `Chart.yaml` under the `dependencies` section
- Studio locks its Rasa OCI dependency in `Chart.lock`
- Run `helm dependency build` after modifying dependencies

## Helm 4 Compatibility

Charts must lint under **both Helm 3 and Helm 4** (CI: Helm 3.15.2 via `ct lint`, Helm 4.2.0 via `helm lint --strict`):

- **Never mutate `.Values`** — Helm 4 makes them read-only; use a local `deepCopy`/`merge` dict
- **Don't branch on `.Capabilities.KubeVersion` for API versions** — hardcode `networking.k8s.io/v1`
- Prefer `deepCopy` over `toYaml | fromYaml` when copying values maps
- OCI release action is still Helm 3.15.2; `helm registry login` takes a domain only in Helm 4

## Testing Instructions

### Before Committing

1. Increment chart `version` in `Chart.yaml`
2. Run `helm lint --strict charts/<CHART>`
3. Run pre-commit hooks:
   ```bash
   pre-commit run --all-files
   ```
4. Commit the generated README.md files along with your changes

### Before Creating a Pull Request

1. Lint the modified chart(s):
   ```bash
   helm lint --strict charts/<CHART>
   ```

2. Ensure chart version is incremented in `Chart.yaml`

3. Run pre-commit to update documentation:
   ```bash
   pre-commit run --all-files
   ```

4. Verify all changes are committed, including updated README.md files

### CI Checks

The CI pipeline automatically runs:

- **Chart linting (Helm 3)**: `ct lint --config ct.yaml` on changed charts (`check-version-increment: true`)
- **Chart linting (Helm 4)**: `helm lint --strict` on studio, rasa, and op-kits
- **Snyk IAC scanning**: renders templates with `--kube-version 1.29.0`, then scans
- **RC gate** (`check-rc.yaml`): blocks `-rc` chart versions from merging to `main`

## Version Management

### Incrementing Chart Versions

When making changes to a chart:

1. Edit `charts/<CHART>/Chart.yaml`
2. Increment the `version` field using semantic versioning:
   - Patch: `1.3.2` → `1.3.3` (bug fixes)
   - Minor: `1.3.2` → `1.4.0` (new features)
   - Major: `1.3.2` → `2.0.0` (breaking changes)

3. The CI will validate version increments automatically

### Release Candidate Versions (`release/*`)

On `release/` branches, increment once and append `-rc.X`:
- Start: `2.0.2` → `2.0.3-rc.0`
- Each subsequent push: bump the rc counter (`-rc.1`, `-rc.2`, …)
- Before merging to `main`: drop the `-rc.X` suffix (final `2.0.3`)

CI blocks `-rc` suffixes on `main`.

## Contribution Workflow

1. **Create a branch**:
   ```bash
   git checkout -b <branch_name>
   ```

2. **Make changes** to chart templates, values, or configuration

3. **Increment chart version** in `charts/<CHART>/Chart.yaml`

4. **Lint your changes**:
   ```bash
   helm lint --strict charts/<CHART>
   ```

5. **Run pre-commit** to update documentation:
   ```bash
   pre-commit run --all-files
   ```

6. **Commit changes** including:
   - Your code changes
   - Updated `Chart.yaml` with new version
   - Auto-generated `README.md` files

7. **Create pull request**

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) with chart scope (`studio`, `rasa`, `op-kits`). See [CONTRIBUTING.md](CONTRIBUTING.md).

## Important Notes

### README.md Files

- README.md files are **auto-generated** from `README.md.gotmpl` templates and `values.yaml` comments
- **Always commit** generated README.md files after running pre-commit
- Do not manually edit README.md files - edit `README.md.gotmpl` and `values.yaml` comments instead

### Chart Dependencies

- Chart dependencies are managed via the `dependencies` section in `Chart.yaml`
- Studio has locked dependencies in `Chart.lock`
- Run `helm dependency build` after modifying dependencies

### Security Scanning

- Security scanning is performed via Snyk IAC in CI
- Templates are generated and scanned automatically
- Fix any high-severity issues before merging

### Chart Testing

- Chart-testing (`ct`) is configured in `ct.yaml`
- Only changed charts are tested to speed up CI
- Test templates are located in `templates/tests/` directories

### Secret References

```yaml
password:
  secretName: "my-secrets"
  secretKey: "SECRET_KEY"
```

Studio app auth uses `app.authSecret` the same way (`AUTH_SECRET`).

## Troubleshooting

### Pre-commit hooks not running

```bash
pre-commit install
```

### README.md not updating

```bash
pre-commit run helm-docs --all-files
```

### Dependency build fails

Ensure Helm can access the required repositories:
- OCI registries may require authentication
- Check `Chart.yaml` for correct repository URLs

### Lint errors

Run with `--strict` flag to see all issues:
```bash
helm lint --strict charts/<CHART>
```

Fix issues before committing.
