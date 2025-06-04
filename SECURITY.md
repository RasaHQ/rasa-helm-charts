# Security Policy

## Reporting a Vulnerability

We take the security of Rasa Helm Charts seriously. If you believe you have found a security vulnerability, please follow these steps:

1. **Do Not** disclose the vulnerability publicly
2. Email the Rasa Security Team at infrasecteam@rasa.com with the following information:
   - Description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact of the vulnerability
   - Any suggested fixes (if available)

### What to Expect

- You will receive an acknowledgment of your report within 48 hours
- We will investigate the issue and keep you updated on our progress
- Once the issue is resolved, we will:
  - Credit you in the security advisory (unless you prefer to remain anonymous)
  - Notify you when the fix is released
  - Add the vulnerability to our security advisories list

## Security Best Practices

When using Rasa Helm Charts, we recommend following these security best practices:

1. **Regular Updates**: Keep your Helm Charts up to date with the latest security patches
2. **Secret Management**: Use Kubernetes secrets for sensitive data
3. **Network Policies**: Apply network policies to restrict pod-to-pod communication
4. **Resource Limits**: Set appropriate resource limits for all containers
5. **Security Context**: Use security contexts to run containers with minimal privileges
6. **TLS**: Enable TLS for all external communications
7. **Authentication**: Use strong authentication mechanisms (e.g., Keycloak)
8. **Authorization**: Implement proper role-based access control (RBAC)

## Security Features

Rasa Helm Charts includes several security features:

- **Pod Security Contexts**: Configurable security contexts for all pods
- **Network Policies**: Optional network policies to restrict traffic
- **Secret Management**: Built-in support for Kubernetes secrets
- **TLS Support**: Configurable TLS for ingress resources
- **Authentication**: Integration with Keycloak for authentication
- **Resource Limits**: Configurable resource limits and requests

## Security Contacts

- Security Team: infrasecteam@rasa.com

## Additional Resources

- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Helm Security Best Practices](https://helm.sh/docs/topics/security/)
- [Security at Rasa](https://rasa.com/security-at-rasa/) 
