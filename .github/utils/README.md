# GitHub Utils

This directory contains utility files used by GitHub Actions workflows.

## Files

### `postgres-test.yaml`
A Kubernetes manifest file that defines a PostgreSQL deployment and service for testing purposes.

**Components:**
- **Service**: `postgres-test` - Exposes PostgreSQL on port 5432
- **Deployment**: `postgres-test` - Runs PostgreSQL 15 Alpine with test configuration

**Configuration:**
- Database: `test`
- User: `test`
- Password: `test`
- Host auth method: `trust` (for testing only)

**Usage:**
This file is applied by CI workflows to provide a PostgreSQL database for testing the Studio Helm chart.

```bash
kubectl apply -f .github/utils/postgres-test.yaml
```

## Note
These files are not GitHub Actions workflows themselves, but rather supporting resources used by workflows in the `.github/workflows/` directory. 
