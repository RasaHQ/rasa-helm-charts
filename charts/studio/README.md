# studio

A Helm chart for Kubernetes

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

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
| backend.environmentVariables[0].name | string | `"DATABASE_URL"` |  |
| backend.environmentVariables[0].valueFrom.secretKeyRef.key | string | `nil` |  |
| backend.environmentVariables[0].valueFrom.secretKeyRef.name | string | `nil` |  |
| backend.environmentVariables[10].name | string | `"KEYCLOAK_URL"` |  |
| backend.environmentVariables[11].name | string | `"KEYCLOAK_REALM"` |  |
| backend.environmentVariables[12].name | string | `"KEYCLOAK_API_USERNAME"` |  |
| backend.environmentVariables[13].name | string | `"KEYCLOAK_API_PASSWORD"` |  |
| backend.environmentVariables[14].name | string | `"KEYCLOAK_API_GRANTTYPE"` |  |
| backend.environmentVariables[1].name | string | `"SECURITY_PROTOCOL"` |  |
| backend.environmentVariables[1].value | string | `"SASL_SSL"` |  |
| backend.environmentVariables[2].name | string | `"SASL_MECHANISM"` |  |
| backend.environmentVariables[3].name | string | `"SASL_USERNAME"` |  |
| backend.environmentVariables[4].name | string | `"SASL_PASSWORD"` |  |
| backend.environmentVariables[5].name | string | `"KAFKA_BROKER_ADDRESS"` |  |
| backend.environmentVariables[6].name | string | `"KAFKA_TOPIC"` |  |
| backend.environmentVariables[7].name | string | `"KAFKA_DLQ_TOPIC"` |  |
| backend.environmentVariables[8].name | string | `"KAFKA_CLIENT_ID"` |  |
| backend.environmentVariables[9].name | string | `"GROUP_ID"` |  |
| backend.image | string | `nil` |  |
| backend.imagePullSecrets | list | `[]` |  |
| backend.ingress.annotations | object | `{}` |  |
| backend.ingress.className | string | `""` |  |
| backend.ingress.enabled | bool | `false` |  |
| backend.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| backend.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| backend.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| backend.ingress.tls | list | `[]` |  |
| backend.livenessProbe.failureThreshold | int | `6` |  |
| backend.livenessProbe.httpGet.path | string | `"/"` |  |
| backend.livenessProbe.httpGet.port | string | `"http"` |  |
| backend.livenessProbe.httpGet.scheme | string | `"HTTP"` |  |
| backend.livenessProbe.initialDelaySeconds | int | `15` |  |
| backend.livenessProbe.periodSeconds | int | `15` |  |
| backend.livenessProbe.successThreshold | int | `1` |  |
| backend.livenessProbe.timeoutSeconds | int | `5` |  |
| backend.nodeSelector | object | `{}` |  |
| backend.podAnnotations | object | `{}` |  |
| backend.podSecurityContext | object | `{}` |  |
| backend.pullPolicy | string | `"IfNotPresent"` |  |
| backend.readinessProbe.failureThreshold | int | `6` |  |
| backend.readinessProbe.httpGet.path | string | `"/"` |  |
| backend.readinessProbe.httpGet.port | string | `"http"` |  |
| backend.readinessProbe.httpGet.scheme | string | `"HTTP"` |  |
| backend.readinessProbe.initialDelaySeconds | int | `15` |  |
| backend.readinessProbe.periodSeconds | int | `15` |  |
| backend.readinessProbe.successThreshold | int | `1` |  |
| backend.readinessProbe.timeoutSeconds | int | `5` |  |
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
| databaseMigration.affinity | object | `{}` |  |
| databaseMigration.autoscaling.enabled | bool | `false` |  |
| databaseMigration.autoscaling.maxReplicas | int | `100` |  |
| databaseMigration.autoscaling.minReplicas | int | `1` |  |
| databaseMigration.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| databaseMigration.fullnameOverride | string | `""` |  |
| databaseMigration.image | string | `nil` |  |
| databaseMigration.imagePullSecrets | list | `[]` |  |
| databaseMigration.ingress.annotations | object | `{}` |  |
| databaseMigration.ingress.className | string | `""` |  |
| databaseMigration.ingress.enabled | bool | `false` |  |
| databaseMigration.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| databaseMigration.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| databaseMigration.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| databaseMigration.ingress.tls | list | `[]` |  |
| databaseMigration.nameOverride | string | `""` |  |
| databaseMigration.nodeSelector | object | `{}` |  |
| databaseMigration.podAnnotations | object | `{}` |  |
| databaseMigration.podSecurityContext | object | `{}` |  |
| databaseMigration.pullPolicy | string | `"IfNotPresent"` |  |
| databaseMigration.replicaCount | int | `1` |  |
| databaseMigration.repository | string | `nil` |  |
| databaseMigration.resources | object | `{}` |  |
| databaseMigration.securityContext | object | `{}` |  |
| databaseMigration.service.port | int | `80` |  |
| databaseMigration.service.type | string | `"ClusterIP"` |  |
| databaseMigration.serviceAccount.annotations | object | `{}` |  |
| databaseMigration.serviceAccount.create | bool | `true` |  |
| databaseMigration.serviceAccount.name | string | `""` |  |
| databaseMigration.tag | string | `""` |  |
| databaseMigration.tolerations | list | `[]` |  |
| eventIngestion.affinity | object | `{}` |  |
| eventIngestion.autoscaling.enabled | bool | `false` |  |
| eventIngestion.autoscaling.maxReplicas | int | `100` |  |
| eventIngestion.autoscaling.minReplicas | int | `1` |  |
| eventIngestion.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| eventIngestion.fullnameOverride | string | `""` |  |
| eventIngestion.image | string | `nil` |  |
| eventIngestion.imagePullSecrets | list | `[]` |  |
| eventIngestion.ingress.annotations | object | `{}` |  |
| eventIngestion.ingress.className | string | `""` |  |
| eventIngestion.ingress.enabled | bool | `false` |  |
| eventIngestion.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| eventIngestion.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| eventIngestion.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| eventIngestion.ingress.tls | list | `[]` |  |
| eventIngestion.nameOverride | string | `""` |  |
| eventIngestion.nodeSelector | object | `{}` |  |
| eventIngestion.podAnnotations | object | `{}` |  |
| eventIngestion.podSecurityContext | object | `{}` |  |
| eventIngestion.pullPolicy | string | `"IfNotPresent"` |  |
| eventIngestion.replicaCount | int | `1` |  |
| eventIngestion.repository | string | `nil` |  |
| eventIngestion.resources | object | `{}` |  |
| eventIngestion.securityContext | object | `{}` |  |
| eventIngestion.service.port | int | `80` |  |
| eventIngestion.service.type | string | `"ClusterIP"` |  |
| eventIngestion.serviceAccount.annotations | object | `{}` |  |
| eventIngestion.serviceAccount.create | bool | `true` |  |
| eventIngestion.serviceAccount.name | string | `""` |  |
| eventIngestion.tag | string | `""` |  |
| eventIngestion.tolerations | list | `[]` |  |
| frontend.affinity | object | `{}` |  |
| frontend.autoscaling.enabled | bool | `false` |  |
| frontend.autoscaling.maxReplicas | int | `100` |  |
| frontend.autoscaling.minReplicas | int | `1` |  |
| frontend.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| frontend.fullnameOverride | string | `""` |  |
| frontend.image | string | `nil` |  |
| frontend.imagePullSecrets | list | `[]` |  |
| frontend.ingress.annotations | object | `{}` |  |
| frontend.ingress.className | string | `""` |  |
| frontend.ingress.enabled | bool | `false` |  |
| frontend.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| frontend.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| frontend.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| frontend.ingress.tls | list | `[]` |  |
| frontend.nameOverride | string | `""` |  |
| frontend.nodeSelector | object | `{}` |  |
| frontend.podAnnotations | object | `{}` |  |
| frontend.podSecurityContext | object | `{}` |  |
| frontend.pullPolicy | string | `"IfNotPresent"` |  |
| frontend.replicaCount | int | `1` |  |
| frontend.repository | string | `nil` |  |
| frontend.resources | object | `{}` |  |
| frontend.securityContext | object | `{}` |  |
| frontend.service.port | int | `80` |  |
| frontend.service.type | string | `"ClusterIP"` |  |
| frontend.serviceAccount.annotations | object | `{}` |  |
| frontend.serviceAccount.create | bool | `true` |  |
| frontend.serviceAccount.name | string | `""` |  |
| frontend.tag | string | `""` |  |
| frontend.tolerations | list | `[]` |  |
| fullnameOverride | string | `""` | Override the full qualified app name |
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
| nameOverride | string | `""` | Override name of app |
