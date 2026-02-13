# AGENTS.md

A guide for AI coding agents working on Rasa Helm Charts.

## Project Overview

This repository contains Helm charts for deploying Rasa products on Kubernetes:
- **Rasa Studio** (`charts/studio/`) - Studio deployment chart
- **Rasa Pro** (`charts/rasa/`) - Rasa Pro deployment chart  
- **Operator Kits** (`charts/op-kits/`) - Operator Kits chart for PostgreSQL, Kafka, and related operators

For user-facing documentation, see [README.md](README.md). For contribution guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).

## Prerequisites

- Kubernetes 1.30+
- Helm 3.2.0+
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
helm template ./charts/<CHART> --output-dir ./output
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

### Chart Version Management

- **Always increment** the `version` field in `charts/<CHART>/Chart.yaml` when making changes
- Use semantic versioning format (e.g., `1.3.2`, `2.2.2`)
- CI checks prevent release candidate versions (`-rc`) in certain branches

### README Generation

- Each chart has a `README.md.gotmpl` template file
- README.md files are auto-generated from `README.md.gotmpl` and `values.yaml` comments
- Always commit generated README.md files after running pre-commit

## Chart Structure Conventions

Each chart follows this structure:

```
charts/<CHART>/
├── Chart.yaml          # Chart metadata and dependencies
├── values.yaml         # Default values with helm-docs comments
├── README.md.gotmpl    # Template for auto-generated README
├── README.md           # Auto-generated documentation
├── templates/          # Kubernetes resource templates
│   ├── _helpers.tpl   # Helper template functions
│   ├── tests/         # Test templates
│   └── network-policy/ # Network policy templates
└── secrets.yaml        # Secrets template (some charts)
```

### Chart Dependencies

- Dependencies are declared in `Chart.yaml` under the `dependencies` section
- Some charts (like `studio`) have locked dependencies in `Chart.lock`
- Run `helm dependency build` after modifying dependencies

## Testing Instructions

### Before Committing

1. Run pre-commit hooks:
   ```bash
   pre-commit run --all-files
   ```

2. Verify README.md files are updated and reflect your changes

3. Commit the generated README.md files along with your changes

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

- **Chart linting**: `ct lint --config ct.yaml` (only on changed charts)
- **Snyk IAC scanning**: Security scanning of generated Helm templates
- **Version checks**: Ensures version increments and prevents RC versions in certain branches

## Version Management

### Incrementing Chart Versions

When making changes to a chart:

1. Edit `charts/<CHART>/Chart.yaml`
2. Increment the `version` field using semantic versioning:
   - Patch: `1.3.2` → `1.3.3` (bug fixes)
   - Minor: `1.3.2` → `1.4.0` (new features)
   - Major: `1.3.2` → `2.0.0` (breaking changes)

3. The CI will validate version increments automatically

### Release Candidate Versions

- CI checks prevent `-rc` versions in certain branches
- Use standard semantic versioning for releases

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

## Important Notes

### README.md Files

- README.md files are **auto-generated** from `README.md.gotmpl` templates and `values.yaml` comments
- **Always commit** generated README.md files after running pre-commit
- Do not manually edit README.md files - edit `README.md.gotmpl` and `values.yaml` comments instead

### Chart Dependencies

- Chart dependencies are managed via the `dependencies` section in `Chart.yaml`
- Some charts (like `studio`) have locked dependencies in `Chart.lock`
- Run `helm dependency build` after modifying dependencies

### Security Scanning

- Security scanning is performed via Snyk IAC in CI
- Templates are generated and scanned automatically
- Fix any high-severity issues before merging

### Chart Testing

- Chart-testing (`ct`) is configured in `ct.yaml`
- Only changed charts are tested to speed up CI
- Test templates are located in `templates/tests/` directories

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
