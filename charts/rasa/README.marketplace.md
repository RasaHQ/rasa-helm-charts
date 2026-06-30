# rasa

AWS Marketplace-specific Rasa Pro Helm chart for EKS

## Prerequisites

- Amazon EKS cluster with Kubernetes 1.30+ and an IAM OIDC provider
- Helm 3.8.0+
- A valid Rasa Pro license key ([see below](#rasa-pro-license))
- An IAM role bound to the Rasa Pro pod service account ([see below](#service-account))

### Rasa Pro License

You need to acquire a Rasa Pro license key from the Rasa sales team through the AWS Marketplace.

Create a secret containing your Rasa Pro license key before installing:
```console
kubectl create secret generic rasa-secrets \
  --from-literal=rasaProLicense="<YOUR_LICENSE_KEY>"
```

### Service Account

Use the following command to create a Kubernetes service account:

```shell
kubectl create namespace <ENTER_NAMESPACE_HERE>
            
eksctl create iamserviceaccount \
    --name <ENTER_SERVICE_ACCOUNT_NAME_HERE> \
    --namespace <ENTER_NAMESPACE_HERE> \
    --cluster <ENTER_YOUR_CLUSTER_NAME_HERE> \
    --attach-role-arn <ENTER_ROLE_ARN_HERE> \
    --approve \
    --override-existing-serviceaccounts
```

Extend the permissions of the IAM role for any other AWS services that your Rasa Pro deployment may need to access to (e.g. S3, MSK, RDS).

## Installation

Use the following commands to launch this software by installing a Helm chart on your Amazon EKS cluster. The Helm CLI version in your launch environment must be 3.7.1 or above.

```shell
helm install --generate-name \
    --namespace <ENTER_NAMESPACE_HERE> ./ \
    --set rasa.serviceAccount.name=<ENTER_SERVICE_ACCOUNT_NAME_HERE> 
```

## Advanced configuration

Please refer to the [official Rasa documentation](https://helm.rasa.com/charts/rasa/).
