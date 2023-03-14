# greeting-service

A Helm chart for Kubernetes

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add foo-bar http://charts.foo-bar.com
$ helm install my-release foo-bar/greeting-service
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `5` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| fullnameOverride | string | `"greeting-service"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"miraai/user-greeting-service"` |  |
| image.tag | string | `"v2"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `"greeting-service"` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| redis.affinity | object | `{}` |  |
| redis.autoscaling.enabled | bool | `false` |  |
| redis.autoscaling.maxReplicas | int | `5` |  |
| redis.autoscaling.minReplicas | int | `1` |  |
| redis.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| redis.container.port | int | `6379` |  |
| redis.image.pullPolicy | string | `"IfNotPresent"` |  |
| redis.image.repository | string | `"redis"` |  |
| redis.image.tag | string | `"alpine3.17"` |  |
| redis.imagePullSecrets | list | `[]` |  |
| redis.nodeSelector | object | `{}` |  |
| redis.podAnnotations | object | `{}` |  |
| redis.podSecurityContext | object | `{}` |  |
| redis.replicaCount | int | `1` |  |
| redis.resources.limits.cpu | string | `"100m"` |  |
| redis.resources.limits.memory | string | `"128Mi"` |  |
| redis.resources.requests.cpu | string | `"100m"` |  |
| redis.resources.requests.memory | string | `"128Mi"` |  |
| redis.securityContext | object | `{}` |  |
| redis.service.port | int | `6379` |  |
| redis.service.type | string | `"ClusterIP"` |  |
| redis.serviceAccount.annotations | string | `nil` |  |
| redis.serviceAccount.create | bool | `true` |  |
| redis.serviceAccount.name | string | `""` |  |
| redis.tolerations | list | `[]` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"200m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext | object | `{}` |  |
| service.port | int | `9090` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |
