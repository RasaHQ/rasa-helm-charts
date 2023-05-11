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
| backend.imagePullSecrets[0].name | string | `"regcred"` |  |
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
| databaseMigration | string | `nil` |  |
| eventIngestion | string | `nil` |  |
| frontend | string | `nil` |  |
| fullnameOverride | string | `""` | Override the full qualified app name |
| keycloak | string | `nil` |  |
| nameOverride | string | `""` | Override name of app |
