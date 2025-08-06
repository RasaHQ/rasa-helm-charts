# Testing Studio Helm Chart

This document describes how to test the Studio Helm chart locally and in CI/CD pipelines.

## Overview

The Studio chart includes several types of tests:

1. **Helm Chart Tests** - Kubernetes pods that run after chart installation
2. **Chart Testing (ct)** - Linting, installation, and upgrade tests
3. **Security Scanning** - Snyk IAC security analysis
4. **Integration Tests** - End-to-end functionality tests

## Local Testing

### Prerequisites

- Helm 3.x
- Kubernetes cluster (kind, minikube, or other)
- chart-testing (ct) tool

### Kubernetes Version Compatibility

The chart has been tested with the following Kubernetes versions:
- **v1.28.15** (stable, recommended for CI/CD)
- **v1.29.14** (latest stable)

For local testing, we recommend using `kindest/node:v1.28.15` as it's the most stable version.

### Running Tests Locally

1. **Install chart-testing:**
   ```bash
   pip install yamale yamllint pytest
   pip install chart-testing
   ```

2. **Create a test cluster:**
   ```bash
   kind create cluster --name test-cluster --image kindest/node:v1.28.15
   ```

3. **Run chart testing:**
   ```bash
   ct lint --config ct.yaml
   ct install --config ct.yaml
   ```

4. **Test specific chart:**
   ```bash
   # Install with test values
   helm install test-studio ./charts/studio --values ./charts/studio/ci/test-values.yaml
   
   # Run Helm tests
   helm test test-studio
   
   # Cleanup
   helm uninstall test-studio
   ```

## Test Types

### 1. Connection Tests

Tests basic connectivity between services:
- Backend service health check
- Web client service accessibility
- Service-to-service communication

### 2. Readiness Tests

Verifies that all deployments are ready:
- Waits for all pods to be in `Ready` state
- Checks deployment availability
- Validates service endpoints

### 3. Values Validation Tests

Validates chart configuration:
- Checks enabled/disabled services
- Validates database configuration
- Ensures required values are set

## Test Values

The chart includes test-specific values in `ci/test-values.yaml`:

- Minimal resource requirements
- Disabled external dependencies
- In-memory database for testing
- Disabled ingress for cluster-only testing

## CI/CD Integration

### GitHub Actions

The chart includes comprehensive GitHub Actions workflows:

1. **Lint and Test** - Runs on PR and main branch
2. **Security Scan** - Snyk IAC security analysis
3. **Integration Test** - End-to-end testing with kind cluster

### Workflow Triggers

- Pull requests affecting charts
- Pushes to main branch
- Manual workflow dispatch

## Test Configuration

### Chart Testing (ct.yaml)

```yaml
# Test configuration
test-charts: true
install-charts: true
upgrade-charts: true

# Parallel testing
parallel: true
parallel-max-workers: 4

# Test values files
additional-values:
  - charts/*/ci/test-values.yaml
```

### Values Configuration

```yaml
testing:
  enabled: true
  timeout: 300
  nodeSelector: {}
  tolerations: []
```

## Best Practices

### 1. Test Isolation

- Use separate namespaces for tests
- Clean up resources after tests
- Use unique release names

### 2. Resource Management

- Use minimal resource requirements in tests
- Set appropriate timeouts
- Handle cleanup in failure scenarios

### 3. Test Coverage

- Test all major components
- Include positive and negative test cases
- Test different value combinations

### 4. Performance

- Use lightweight test images
- Minimize test execution time
- Run tests in parallel when possible

## Troubleshooting

### Common Issues

1. **Test Timeouts**
   - Increase timeout values
   - Check resource availability
   - Verify image pull policies

2. **Service Connectivity**
   - Check service names and ports
   - Verify network policies
   - Ensure proper DNS resolution

3. **Resource Constraints**
   - Adjust resource limits in test values
   - Use smaller test images
   - Optimize test configurations

### Debug Commands

```bash
# Check test pod logs
kubectl logs -l test=connection

# Verify service endpoints
kubectl get endpoints

# Check pod status
kubectl get pods -l app.kubernetes.io/instance=test-studio

# Describe test pods
kubectl describe pod -l test=connection
```

## Contributing

When adding new tests:

1. Follow the existing test structure
2. Use appropriate test images
3. Include proper cleanup
4. Add documentation
5. Update CI workflows if needed

## References

- [Helm Chart Testing](https://github.com/helm/chart-testing)
- [Helm Test Hooks](https://helm.sh/docs/topics/chart_tests/)
- [Kind Cluster](https://kind.sigs.k8s.io/)
- [Snyk IAC](https://snyk.io/product/infrastructure-as-code-security/) 
