# studio

A Helm chart for Kubernetes

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm pull oci://LOCATION-docker.pkg.dev/PROJECT/REPOSITORY/IMAGE --version VERSION
$ helm install RELEASE oci://LOCATION-docker.pkg.dev/PROJECT/REPOSITORY/studio --version VERSION
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backend.affinity | object | `{}` |  |
| backend.autoscaling.enabled | bool | `false` |  |
| backend.autoscaling.maxReplicas | int | `100` |  |
| backend.autoscaling.minReplicas | int | `1` |  |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| backend.fullnameOverride | string | `""` |  |
| backend.image | string | `nil` |  |
| backend.imagePullSecrets | list | `[]` |  |
| backend.ingress.annotations | object | `{}` |  |
| backend.ingress.className | string | `""` |  |
| backend.ingress.enabled | bool | `false` |  |
| backend.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| backend.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| backend.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| backend.ingress.tls | list | `[]` |  |
| backend.nameOverride | string | `""` |  |
| backend.nodeSelector | object | `{}` |  |
| backend.podAnnotations | object | `{}` |  |
| backend.podSecurityContext | object | `{}` |  |
| backend.pullPolicy | string | `"IfNotPresent"` |  |
| backend.replicaCount | int | `1` |  |
| backend.repository | string | `nil` |  |
| backend.resources | object | `{}` |  |
| backend.securityContext | object | `{}` |  |
| backend.service.port | int | `4000` |  |
| backend.service.type | string | `"ClusterIP"` |  |
| backend.serviceAccount.annotations | object | `{}` |  |
| backend.serviceAccount.create | bool | `true` |  |
| backend.serviceAccount.name | string | `""` |  |
| backend.tag | string | `""` |  |
| backend.tolerations | list | `[]` |  |
| event-ingestion.affinity | object | `{}` |  |
| event-ingestion.autoscaling.enabled | bool | `false` |  |
| event-ingestion.autoscaling.maxReplicas | int | `100` |  |
| event-ingestion.autoscaling.minReplicas | int | `1` |  |
| event-ingestion.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| event-ingestion.fullnameOverride | string | `""` |  |
| event-ingestion.image | string | `nil` |  |
| event-ingestion.imagePullSecrets | list | `[]` |  |
| event-ingestion.ingress.annotations | object | `{}` |  |
| event-ingestion.ingress.className | string | `""` |  |
| event-ingestion.ingress.enabled | bool | `false` |  |
| event-ingestion.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| event-ingestion.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| event-ingestion.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| event-ingestion.ingress.tls | list | `[]` |  |
| event-ingestion.nameOverride | string | `""` |  |
| event-ingestion.nodeSelector | object | `{}` |  |
| event-ingestion.podAnnotations | object | `{}` |  |
| event-ingestion.podSecurityContext | object | `{}` |  |
| event-ingestion.pullPolicy | string | `"IfNotPresent"` |  |
| event-ingestion.replicaCount | int | `1` |  |
| event-ingestion.repository | string | `nil` |  |
| event-ingestion.resources | object | `{}` |  |
| event-ingestion.securityContext | object | `{}` |  |
| event-ingestion.service.port | int | `80` |  |
| event-ingestion.service.type | string | `"ClusterIP"` |  |
| event-ingestion.serviceAccount.annotations | object | `{}` |  |
| event-ingestion.serviceAccount.create | bool | `true` |  |
| event-ingestion.serviceAccount.name | string | `""` |  |
| event-ingestion.tag | string | `""` |  |
| event-ingestion.tolerations | list | `[]` |  |
| keycloak.affinity | object | `{}` |  |
| keycloak.autoscaling.enabled | bool | `false` |  |
| keycloak.autoscaling.maxReplicas | int | `100` |  |
| keycloak.autoscaling.minReplicas | int | `1` |  |
| keycloak.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| keycloak.fullnameOverride | string | `""` |  |
| keycloak.image | string | `nil` |  |
| keycloak.imagePullSecrets | list | `[]` |  |
| keycloak.ingress.annotations | object | `{}` |  |
| keycloak.ingress.className | string | `""` |  |
| keycloak.ingress.enabled | bool | `false` |  |
| keycloak.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| keycloak.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| keycloak.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| keycloak.ingress.tls | list | `[]` |  |
| keycloak.nameOverride | string | `""` |  |
| keycloak.nodeSelector | object | `{}` |  |
| keycloak.podAnnotations | object | `{}` |  |
| keycloak.podSecurityContext | object | `{}` |  |
| keycloak.pullPolicy | string | `"IfNotPresent"` |  |
| keycloak.replicaCount | int | `1` |  |
| keycloak.repository | string | `nil` |  |
| keycloak.resources | object | `{}` |  |
| keycloak.securityContext | object | `{}` |  |
| keycloak.service.port | int | `8080` |  |
| keycloak.service.type | string | `"ClusterIP"` |  |
| keycloak.serviceAccount.annotations | object | `{}` |  |
| keycloak.serviceAccount.create | bool | `true` |  |
| keycloak.serviceAccount.name | string | `""` |  |
| keycloak.tag | string | `""` |  |
| keycloak.tolerations | list | `[]` |  |
| migration-server.affinity | object | `{}` |  |
| migration-server.autoscaling.enabled | bool | `false` |  |
| migration-server.autoscaling.maxReplicas | int | `100` |  |
| migration-server.autoscaling.minReplicas | int | `1` |  |
| migration-server.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| migration-server.fullnameOverride | string | `""` |  |
| migration-server.image | string | `nil` |  |
| migration-server.imagePullSecrets | list | `[]` |  |
| migration-server.ingress.annotations | object | `{}` |  |
| migration-server.ingress.className | string | `""` |  |
| migration-server.ingress.enabled | bool | `false` |  |
| migration-server.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| migration-server.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| migration-server.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| migration-server.ingress.tls | list | `[]` |  |
| migration-server.nameOverride | string | `""` |  |
| migration-server.nodeSelector | object | `{}` |  |
| migration-server.podAnnotations | object | `{}` |  |
| migration-server.podSecurityContext | object | `{}` |  |
| migration-server.pullPolicy | string | `"IfNotPresent"` |  |
| migration-server.replicaCount | int | `1` |  |
| migration-server.repository | string | `nil` |  |
| migration-server.resources | object | `{}` |  |
| migration-server.securityContext | object | `{}` |  |
| migration-server.service.port | int | `80` |  |
| migration-server.service.type | string | `"ClusterIP"` |  |
| migration-server.serviceAccount.annotations | object | `{}` |  |
| migration-server.serviceAccount.create | bool | `true` |  |
| migration-server.serviceAccount.name | string | `""` |  |
| migration-server.tag | string | `""` |  |
| migration-server.tolerations | list | `[]` |  |
| web-client.affinity | object | `{}` |  |
| web-client.autoscaling.enabled | bool | `false` |  |
| web-client.autoscaling.maxReplicas | int | `100` |  |
| web-client.autoscaling.minReplicas | int | `1` |  |
| web-client.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| web-client.fullnameOverride | string | `""` |  |
| web-client.image | string | `nil` |  |
| web-client.imagePullSecrets | list | `[]` |  |
| web-client.ingress.annotations | object | `{}` |  |
| web-client.ingress.className | string | `""` |  |
| web-client.ingress.enabled | bool | `false` |  |
| web-client.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| web-client.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| web-client.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| web-client.ingress.tls | list | `[]` |  |
| web-client.nameOverride | string | `""` |  |
| web-client.nodeSelector | object | `{}` |  |
| web-client.podAnnotations | object | `{}` |  |
| web-client.podSecurityContext | object | `{}` |  |
| web-client.pullPolicy | string | `"IfNotPresent"` |  |
| web-client.replicaCount | int | `1` |  |
| web-client.repository | string | `nil` |  |
| web-client.resources | object | `{}` |  |
| web-client.securityContext | object | `{}` |  |
| web-client.service.port | int | `80` |  |
| web-client.service.type | string | `"ClusterIP"` |  |
| web-client.serviceAccount.annotations | object | `{}` |  |
| web-client.serviceAccount.create | bool | `true` |  |
| web-client.serviceAccount.name | string | `""` |  |
| web-client.tag | string | `""` |  |
| web-client.tolerations | list | `[]` |  |
