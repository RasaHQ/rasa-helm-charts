# greeting-service

A Helm chart for Kubernetes

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm pull oci://LOCATION-docker.pkg.dev/PROJECT/REPOSITORY/IMAGE --version VERSION
$ helm install RELEASE oci://LOCATION-docker.pkg.dev/PROJECT/REPOSITORY/greeting-service --version VERSION
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Specifies affinity |
| autoscaling.enabled | bool | `false` | Specifies whether to enable autoscaling |
| autoscaling.maxReplicas | int | `5` | Specifies maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Specifies minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies target CPU utilization in precentages when to start scaling based on CPU Use `targetMemoryUtilizationPercentage` for scaling based on Memory utilization |
| fullnameOverride | string | `"greeting-service"` | Full chart name override |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"miraai/user-greeting-service"` | URL to the image repository |
| image.tag | string | `"v2"` | Image tag Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Image pull secrets for private repositories |
| ingress.annotations | object | `{}` | Annotation to add to the ingress |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Specifies whether an ingress should be created |
| ingress.hosts[0] | object | `{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}` | Ingress hosts |
| ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"ImplementationSpecific"}` | Ingress hosts path |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` | Ingress hosts path type |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `"greeting-service"` | Chart name override |
| nodeSelector | object | `{}` | Specifies node selector |
| podAnnotations | object | `{}` | Annotations to add to the pods |
| podSecurityContext | object | `{}` | Pod security context |
| redis.affinity | object | `{}` | Specifies Redis affinity |
| redis.autoscaling.enabled | bool | `false` | Specifies whether to enable autoscaling |
| redis.autoscaling.maxReplicas | int | `5` | Specifies maximum number of replicas |
| redis.autoscaling.minReplicas | int | `1` | Specifies minimum number of replicas |
| redis.autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies target CPU utilization in precentages when to start scaling based on CPU Use `targetMemoryUtilizationPercentage` for scaling based on Memory utilization |
| redis.container.port | int | `6379` | Redis container port |
| redis.image.pullPolicy | string | `"IfNotPresent"` | Redis image pull policy |
| redis.image.repository | string | `"redis"` | Redis image repository |
| redis.image.tag | string | `"alpine3.17"` | Redis image tag |
| redis.imagePullSecrets | list | `[]` |  |
| redis.nodeSelector | object | `{}` |  |
| redis.podAnnotations | object | `{}` |  |
| redis.podSecurityContext | object | `{}` | Redis pod security context |
| redis.replicaCount | int | `1` | Specifies Redis replica counts |
| redis.resources.limits | object | `{"cpu":"100m","memory":"128Mi"}` | Redis resource limits |
| redis.resources.limits.cpu | string | `"100m"` | Redis CPU resource limits |
| redis.resources.limits.memory | string | `"128Mi"` | Redis Memory resource limits |
| redis.resources.requests.cpu | string | `"100m"` | Redis CPU resource requests |
| redis.resources.requests.memory | string | `"128Mi"` | Redis Memory resource requests |
| redis.securityContext | object | `{}` | Redis security context |
| redis.service.port | int | `6379` | Redis service port |
| redis.service.type | string | `"ClusterIP"` | Redis service type |
| redis.serviceAccount.annotations | string | `nil` | Specifies Redis service account annotations |
| redis.serviceAccount.create | bool | `true` | Specifies whether to enable Redis service account creation |
| redis.serviceAccount.name | string | `""` | Specifies Redis service account name. If left empty, default service account name will be used. |
| redis.tolerations | list | `[]` | Specifies Redis tolerations |
| replicaCount | int | `1` | Number of replicas |
| resources.limits | object | `{"cpu":"200m","memory":"128Mi"}` | Resource limits |
| resources.limits.cpu | string | `"200m"` | Resource CPU limits |
| resources.limits.memory | string | `"128Mi"` | Resource Memory limits |
| resources.requests.cpu | string | `"100m"` | Resource CPU requests |
| resources.requests.memory | string | `"128Mi"` | Resource Memory requests |
| securityContext | object | `{}` | Security context |
| service.port | int | `9090` | Service port |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Specifies tolerations |
