# rasa

[AWS Marketplace](https://aws.amazon.com/marketplace)-specific Rasa Pro Helm chart for EKS

## Prerequisites

- [AWS License Manager](https://aws.amazon.com/license-manager/) enabled in the AWS account where Rasa Pro was purchased on AWS Marketplace.
- [Amazon EKS](https://aws.amazon.com/eks/) cluster with Kubernetes 1.30+ and an [IAM OIDC](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) provider, in the same AWS account as above.
- [AWS CLI](https://aws.amazon.com/cli/) and [eksctl](https://eksctl.io/) installed, and configured to access the AWS account.
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) installed and configured to access the EKS cluster.
- [Helm CLI](https://helm.sh/docs/intro/install/) installed with version 3.7.1 or above.
- Appropriate IAM role bound to the Rasa Pro service account ([see below](#service-account)).
- Valid Rasa Pro license key ([see below](#rasa-pro-license)).

### Service Account

Use the following command to create a Kubernetes service account:

```shell
kubectl create namespace rasa

eksctl create iamserviceaccount \
    --name rasa \
    --namespace rasa \
    --cluster <ENTER_YOUR_CLUSTER_NAME_HERE> \
    --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringFullAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringRegisterUsage \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AWSLicenseManagerConsumptionPolicy \
    --approve \
    --override-existing-serviceaccounts
```

Add any additional policy ARNs to this service account in order to grant access to any AWS services that your Rasa Pro deployment may depend on (e.g. [S3](https://aws.amazon.com/s3/), [MSK](https://aws.amazon.com/msk/), [RDS](https://aws.amazon.com/rds/)).

### Rasa Pro License

First, acquire a valid Rasa Pro license key from the Rasa team through the AWS Marketplace.

Use the following command to store that license key as a Kubernetes secret in your Amazon EKS cluster:

```shell
kubectl create secret generic rasa-secrets --namespace rasa \
  --from-literal=rasaProLicense="<YOUR_LICENSE_KEY>"
```

## Installation

Use the following command from inside the Helm chart directory to launch this software by installing a Helm chart on your Amazon EKS cluster.

```shell
helm install rasa --namespace rasa ./
```

## Advanced Configuration

Please refer to the [official Rasa documentation](https://helm.rasa.com/charts/rasa/).
