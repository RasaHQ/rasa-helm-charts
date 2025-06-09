# Security Policy

## Reporting a Vulnerability

We take the security of Rasa Helm Charts seriously. If you believe you have found a security vulnerability, please follow these steps:

- Please allow us **90 days** to fix an acknowledged issue before publicly disclosing.
- Email the Rasa Security Team at security@rasa.com with the following information:
   - Description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact of the vulnerability
   - Any suggested fixes (if available)

### What to Expect

We will review the information sent and prioritise any confirmed vulnerabilities in line with our [Responsible Disclosure policy](https://rasa.com/responsible-disclosure-policy/). 
We will investigate all legitimate reports and do our best to fix the problem quickly. Please allow us 90 days to fix an acknowledged issue before publicly disclosing. If you haven't already done so, we recommend reading the [policy](https://rasa.com/responsible-disclosure-policy/). 


If required, in line with our Responsible Disclosure Policy, we will:
  - Credit you in the security advisory (unless you prefer to remain anonymous)
  - Notify you when the fix is released
  - Add the vulnerability to our security advisories list

## Security Best Practices

When using Rasa Helm Charts, we recommend following these security best practices:

1. **Regular Updates**: Keep your Helm Charts up to date with the latest security patches
2. **Secret Management**: Use Kubernetes secrets for sensitive data
3. **Network Policies**: Apply network policies to restrict pod-to-pod communicationg
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

- Security Team: security@rasa.com

## Additional Resources

- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Helm Security Best Practices](https://helm.sh/docs/topics/security/)
- [Security at Rasa](https://rasa.com/security-at-rasa/) 
