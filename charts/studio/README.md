# studio

This chart bootstraps Studio deployment on a Kubernetes cluster using the Helm package manager.

![Version: 2.0.0-rc7](https://img.shields.io/badge/Version-2.0.0--rc7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 2.0.0-rc7
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Pull the Chart

To pull chart contents for your own convenience:

```console
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 2.0.0-rc7
```

## General Configuration

- **imagePullSecrets**: If you're using a private Docker registry, provide the necessary credentials in this section.

> **Note:** For application specific settings, please refer to our [documentation](https://rasa.com/docs/) and bellow you can find the full list of values.

## Important Notes on `ingressHost` Anchor

The `config.ingressHost` field in the `values.yaml` file is defined with an **anchor** (`&dns_hostname`) to ensure consistency and reusability across the Helm chart.

### Example:
```yaml
# values.yaml
config:
  ingressHost: &dns_hostname INGRESS.HOST.NAME
```

### Guidelines:
Do *NOT* delete or modify the anchor (`&dns_hostname`).
If you need to change the ingress host, only modify the value (e.g., `INGRESS.HOST.NAME`) while keeping the anchor intact.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backend.additionalContainers | list | `[]` | backend.additionalContainers allows to specify additional containers for the deployment |
| backend.affinity | object | `{}` | backend.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| backend.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | backend.autoscaling specifies the HPA settings |
| backend.autoscaling.enabled | bool | `false` | autoscaling.enabled specifies whether autoscaling should be enabled |
| backend.autoscaling.maxReplicas | int | `100` | autoscaling.maxReplicas specifies the maximum number of replicas |
| backend.autoscaling.minReplicas | int | `1` | autoscaling.minReplicas specifies the minimum number of replicas |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `80` | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage |
| backend.envFrom | list | `[]` | backend.envFrom is used to add environment variables from ConfigMap or Secret |
| backend.environmentVariables | object | `{"DATABASE_URL":{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}},"DELETE_CONVERSATIONS_CRON_EXPRESSION":{"value":"0 * * * *"},"DELETE_CONVERSATIONS_OLDER_THAN_HOURS":{"value":""},"KEYCLOAK_API_CLIENT_ID":{"value":"admin-cli"},"KEYCLOAK_API_PASSWORD":{"secret":{"key":"KEYCLOAK_API_PASSWORD","name":"studio-secrets"}},"KEYCLOAK_API_USERNAME":{"value":"realmadmin"},"KEYCLOAK_REALM":{"value":"rasa-studio"}}` | backend.environmentVariables defines environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| backend.environmentVariables.DATABASE_URL | object | `{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}}` | The URL of the database to connect to in the format postgresql://${database.username}:${database.password}@${database.host}:${database.port}/studio?schema=public |
| backend.environmentVariables.DELETE_CONVERSATIONS_CRON_EXPRESSION | object | `{"value":"0 * * * *"}` | https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax  ┌───────────── minute (0 - 59) | ┌───────────── hour (0 - 23) │ │ ┌───────────── day of the month (1 - 31) │ │ │ ┌───────────── month (1 - 12) │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday) │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ * * * * * |
| backend.environmentVariables.DELETE_CONVERSATIONS_OLDER_THAN_HOURS | object | `{"value":""}` | run if the "DELETE_CONVERSATIONS_OLDER_THAN_HOURS" value is left undefined. |
| backend.environmentVariables.KEYCLOAK_API_PASSWORD | object | `{"secret":{"key":"KEYCLOAK_API_PASSWORD","name":"studio-secrets"}}` | These credentials are used by Studio Backend Server to communicate with Keycloak’s user management module |
| backend.environmentVariables.KEYCLOAK_API_USERNAME | object | `{"value":"realmadmin"}` | These credentials are used by Studio Backend Server to communicate with Keycloak’s user management module |
| backend.image | object | `{"name":"studio-backend","pullPolicy":"IfNotPresent"}` | Define image settings |
| backend.image.name | string | `"studio-backend"` | image.name specifies image repository |
| backend.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| backend.ingress | object | `{"annotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` | Configure the ingress resource that allows you to access the deployment installation. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| backend.ingress.annotations | object | `{}` | ingress.annotations defines annotations to add to the ingress |
| backend.ingress.className | string | `""` | ingress.className specifies the ingress className to be used |
| backend.ingress.enabled | bool | `true` | ingress.enabled specifies whether an ingress service should be created |
| backend.ingress.labels | object | `{}` | ingress.labels defines labels to add to the ingress |
| backend.ingress.tls | list | `[]` | ingress.tls spefices the TLS configuration for ingress |
| backend.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| backend.migration | object | `{"enable":true,"image":{"name":"studio-database-migration","pullPolicy":"IfNotPresent"},"waitForIt":false,"waitFotItContainer":{"image":"postgres:16.1"}}` | Define Studio Database Migration job settings |
| backend.migration.enable | bool | `true` | migration.enable specifies whether a database migration job should be created |
| backend.migration.image | object | `{"name":"studio-database-migration","pullPolicy":"IfNotPresent"}` | migration.image specifies which image database migration job should use |
| backend.migration.image.name | string | `"studio-database-migration"` | image.name specifies the repository of the image |
| backend.migration.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| backend.nodeSelector | object | `{}` | backend.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| backend.podAnnotations | object | `{}` | backend.podAnnotations defines annotations to add to the pod |
| backend.podSecurityContext | object | `{"enabled":true}` | backend.podSecurityContext defines pod security context |
| backend.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| backend.replicaCount | int | `1` | replicaCount specifies number of replicas |
| backend.resources | object | `{}` | backend.resources specifies the resources limits and requests |
| backend.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | backend.securityContext defines security context that allows you to overwrite the pod-level security context |
| backend.service | object | `{"port":80,"targetPort":4000,"type":"ClusterIP"}` | Define service |
| backend.service.port | int | `80` | service.port specifies service port |
| backend.service.targetPort | int | `4000` | service.targetPort specifies service target port |
| backend.service.type | string | `"ClusterIP"` | service.type specifies service type |
| backend.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Define service account |
| backend.serviceAccount.annotations | object | `{}` | serviceAccount.annotations defines annotations to add to the service account |
| backend.serviceAccount.create | bool | `false` | serviceAccount.create specifies whether a service account should be created |
| backend.serviceAccount.name | string | `""` | serviceAccount.name defines the name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| backend.tolerations | list | `[]` | backend.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| config.connectionType | string | `"http"` | Define if you will be using https or http with the ingressHost |
| config.database | object | `{"host":"","keycloakDatabaseName":"keycloak","password":{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"},"port":"5432","preferSSL":"true","rejectUnauthorized":"","username":""}` | The postgres database instance details for Studio to connect to. |
| config.database.host | string | `""` | The database host name |
| config.database.keycloakDatabaseName | string | `"keycloak"` | The database name for keycloak user management service |
| config.database.password | object | `{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"}` | The database password |
| config.database.port | string | `"5432"` | The database port |
| config.database.preferSSL | string | `"true"` | Set to true if you want to use SSL for db connection |
| config.database.username | string | `""` | The database username |
| config.ingressHost | string | `"INGRESS.HOST.NAME"` | If you need to update the host name, only change the value (INGRESS.HOST.NAME), keeping the anchor intact. |
| config.keycloak.adminPassword | object | `{"secretKey":"KEYCLOAK_ADMIN_PASSWORD","secretName":"studio-secrets"}` | The admin password for Keycloak. This password is used to login to Keycloak admin console. |
| config.keycloak.adminUsername | string | `"kcadmin"` | The admin username for Keycloak. This username is used to login to Keycloak admin console. |
| config.keycloak.url | string | `""` | config.keycloak.url allows to override the default service endpoint; format is `http(s)://<ingressHost>/auth`. Required only if your cluster redirects internal HTTP traffic to HTTPS |
| deploymentAnnotations | object | `{}` | deploymentAnnotations defines annotations to add to all Studio deployments |
| deploymentLabels | object | `{}` | deploymentLabels defines labels to add to all Studio deployment |
| dnsConfig | object | `{}` | dnsConfig specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | dnsPolicy specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| eventIngestion.additionalContainers | list | `[]` | eventIngestion.additionalContainers allows to specify additional containers for the deployment |
| eventIngestion.affinity | object | `{}` | eventIngestion.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| eventIngestion.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | eventIngestion.autoscaling specifies the HPA settings |
| eventIngestion.autoscaling.enabled | bool | `false` | autoscaling.enabled specifies whether autoscaling should be enabled |
| eventIngestion.autoscaling.maxReplicas | int | `100` | autoscaling.maxReplicas specifies the maximum number of replicas |
| eventIngestion.autoscaling.minReplicas | int | `1` | autoscaling.minReplicas specifies the minimum number of replicas |
| eventIngestion.autoscaling.targetCPUUtilizationPercentage | int | `80` | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage |
| eventIngestion.envFrom | list | `[]` | eventIngestion.envFrom is used to add environment variables from ConfigMap or Secret |
| eventIngestion.environmentVariables | object | `{"DATABASE_URL":{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}},"KAFKA_BROKER_ADDRESS":{"value":""},"KAFKA_CA_FILE":{"value":""},"KAFKA_CERT_FILE":{"value":""},"KAFKA_CUSTOM_SSL":{"value":""},"KAFKA_DLQ_TOPIC":{"value":"rasa-events-dlq"},"KAFKA_ENABLE_SSL":{"value":""},"KAFKA_GROUP_ID":{"value":"studio"},"KAFKA_KEY_FILE":{"value":""},"KAFKA_REJECT_UNAUTHORIZED":{"value":""},"KAFKA_SASL_MECHANISM":{"value":""},"KAFKA_SASL_PASSWORD":{"secret":{"key":"KAFKA_SASL_PASSWORD","name":"studio-secrets"}},"KAFKA_SASL_USERNAME":{"value":""},"KAFKA_TOPIC":{"value":"rasa-events"},"NODE_TLS_REJECT_UNAUTHORIZED":{"value":""}}` | eventIngestion.environmentVariables defines environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| eventIngestion.environmentVariables.DATABASE_URL | object | `{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}}` | The URL of the database to connect to in the format postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}?schema=public. This should be same as the one defined for backend. |
| eventIngestion.environmentVariables.KAFKA_BROKER_ADDRESS | object | `{"value":""}` | Kafka broker address |
| eventIngestion.environmentVariables.KAFKA_CA_FILE | object | `{"value":""}` | Path to the CA file |
| eventIngestion.environmentVariables.KAFKA_CERT_FILE | object | `{"value":""}` | Path to the client certificate file |
| eventIngestion.environmentVariables.KAFKA_CUSTOM_SSL | object | `{"value":""}` | Set to true if you want to use SSL with custom certs |
| eventIngestion.environmentVariables.KAFKA_DLQ_TOPIC | object | `{"value":"rasa-events-dlq"}` | Kafka topic to which unprocessed Rasa Pro assistant events will be pushed by Studio. Make sure that you pre-create these on your own. |
| eventIngestion.environmentVariables.KAFKA_ENABLE_SSL | object | `{"value":""}` | Set to true if you want to use SSL |
| eventIngestion.environmentVariables.KAFKA_GROUP_ID | object | `{"value":"studio"}` | This is the Kafka group id that should be unique for Studio so that Studio can receive a copy of all the Rasa Pro events streamed to the topic. |
| eventIngestion.environmentVariables.KAFKA_KEY_FILE | object | `{"value":""}` | Path to the client key file |
| eventIngestion.environmentVariables.KAFKA_REJECT_UNAUTHORIZED | object | `{"value":""}` | Defaults to true, the server certificate is verified against the list of supplied CA |
| eventIngestion.environmentVariables.KAFKA_SASL_MECHANISM | object | `{"value":""}` | Supported values are plain, SCRAM-SHA-256 or SCRAM-SHA-512. You can leave it empty if you are not using SASL. |
| eventIngestion.environmentVariables.KAFKA_TOPIC | object | `{"value":"rasa-events"}` | Kafka topic to which to Rasa Pro assistant will publish events. Make sure that you pre-create these on your own. |
| eventIngestion.environmentVariables.NODE_TLS_REJECT_UNAUTHORIZED | object | `{"value":""}` | Instructs the application to allow untrusted certificates. Set this to 0 if using untrusted certificates for Kafka. |
| eventIngestion.image | object | `{"name":"studio-event-ingestion","pullPolicy":"IfNotPresent"}` | Define image settings |
| eventIngestion.image.name | string | `"studio-event-ingestion"` | image.name specifies image repository |
| eventIngestion.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| eventIngestion.nodeSelector | object | `{}` | eventIngestion.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| eventIngestion.podAnnotations | object | `{}` | eventIngestion.podAnnotations defines to add to the pod |
| eventIngestion.podSecurityContext | object | `{"enabled":true}` | eventIngestion.podSecurityContext defines pod security context |
| eventIngestion.replicaCount | int | `1` | replicaCount specifies number of replicas |
| eventIngestion.resources | object | `{}` | eventIngestion.resources specifies the resources limits and requests |
| eventIngestion.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | eventIngestion.securityContext defines security context that allows you to overwrite the pod-level security context |
| eventIngestion.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Define service account |
| eventIngestion.serviceAccount.annotations | object | `{}` | serviceAccount.annotations defines annotations to add to the service account |
| eventIngestion.serviceAccount.create | bool | `false` | serviceAccount.create specifies whether a service account should be created |
| eventIngestion.serviceAccount.name | string | `""` | serviceAccount.name defines the name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| eventIngestion.tolerations | list | `[]` | eventIngestion.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| eventIngestion.volumeMounts | list | `[]` | eventIngestion.volumeMounts specifies additional volumes to mount in the Studio event ingestion container |
| eventIngestion.volumes | list | `[]` | eventIngestion.volumes specify additional volumes for the Studio event ingestion container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| fullnameOverride | string | `""` | Override the full qualified app name |
| global.additionalDeploymentLabels | object | `{}` | global.additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| global.ingressHost | string | `nil` |  |
| hostNetwork | bool | `false` | Controls whether the pod may use the node network namespace |
| imagePullSecrets | list | `[]` | imagePullSecret defines repository pull secrets |
| keycloak.additionalContainers | list | `[]` | keycloak.additionalContainers allows to specify additional containers for the deployment |
| keycloak.affinity | object | `{}` | keycloak.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| keycloak.envFrom | list | `[]` | keycloak.envFrom is used to add environment variables from ConfigMap or Secret |
| keycloak.environmentVariables | object | `{"KC_PROXY":{"value":"edge"}}` | keycloak.environmentVariables defines environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| keycloak.image | object | `{"name":"studio-keycloak","pullPolicy":"IfNotPresent"}` | Define image settings |
| keycloak.image.name | string | `"studio-keycloak"` | image.name specifies image repository |
| keycloak.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| keycloak.ingress | object | `{"annotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` | Configure the ingress resource that allows you to access the deployment installation. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| keycloak.ingress.annotations | object | `{}` | ingress.annotations defines annotations to add to the ingress |
| keycloak.ingress.className | string | `""` | ingress.className specifies the ingress className to be used |
| keycloak.ingress.enabled | bool | `true` | ingress.enabled specifies whether an ingress service should be created |
| keycloak.ingress.labels | object | `{}` | ingress.labels defines labels to add to the ingress |
| keycloak.ingress.tls | list | `[]` | ingress.tls spefices the TLS configuration for ingress |
| keycloak.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/auth","port":8080,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| keycloak.nodeSelector | object | `{}` | keycloak.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| keycloak.podAnnotations | object | `{}` | keycloak.podAnnotations defines annotations to add to the pod |
| keycloak.podSecurityContext | object | `{"enabled":true}` | keycloak.podSecurityContext defines pod security context |
| keycloak.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/auth","port":8080,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| keycloak.replicaCount | int | `1` | replicaCount specifies number of replicas |
| keycloak.resources | object | `{}` | keycloak.resources specifies the resources limits and requests |
| keycloak.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | keycloak.securityContext defines security context that allows you to overwrite the pod-level security context |
| keycloak.service | object | `{"port":80,"targetPort":8080,"type":"ClusterIP"}` | Define service |
| keycloak.service.port | int | `80` | service.port specifies service port |
| keycloak.service.targetPort | int | `8080` | service.targetPort specifies service target port |
| keycloak.service.type | string | `"ClusterIP"` | service.type specifies service type |
| keycloak.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Define service account |
| keycloak.serviceAccount.annotations | object | `{}` | serviceAccount.annotations defines annotations to add to the service account |
| keycloak.serviceAccount.create | bool | `false` | serviceAccount.create specifies whether a service account should be created |
| keycloak.serviceAccount.name | string | `""` | serviceAccount.name defines the name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| keycloak.tolerations | list | `[]` | keycloak.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| nameOverride | string | `""` | Override name of app |
| networkPolicy.denyAll | bool | `false` | networkPolicy.denyAll defines whether to apply denyAll network policy |
| networkPolicy.enabled | bool | `false` | networkPolicy.enabled specifies whether to enable network policies |
| networkPolicy.nodeCIDR | list | `[]` | networkPolicy.nodeCIDR allows for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes |
| podLabels | object | `{}` | podLabels defines labels to add to all Studio pod(s) |
| rasa.enabled | bool | `true` |  |
| rasa.fullnameOverride | string | `"rasapro"` |  |
| rasa.rasa.command[0] | string | `"python"` |  |
| rasa.rasa.command[1] | string | `"-m"` |  |
| rasa.rasa.command[2] | string | `"rasa.model_service"` |  |
| rasa.rasa.envFrom[0].configMapRef.name | string | `"shared-environment"` |  |
| rasa.rasa.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` |  |
| rasa.rasa.image.tag | string | `"3.11.0rc1"` |  |
| rasa.rasa.ingress.annotations | object | `{}` |  |
| rasa.rasa.ingress.enabled | bool | `true` |  |
| rasa.rasa.ingress.hosts[0] | object | `{"host":"INGRESS.HOST.NAME","paths":[{"path":"/talk","pathType":"Prefix"}]}` | Please update the below URL with the correct host name of the Studio deployment |
| rasa.rasa.livenessProbe.enabled | bool | `true` |  |
| rasa.rasa.livenessProbe.failureThreshold | int | `6` |  |
| rasa.rasa.livenessProbe.httpGet.path | string | `"/"` |  |
| rasa.rasa.livenessProbe.httpGet.port | int | `8000` |  |
| rasa.rasa.livenessProbe.httpGet.scheme | string | `"HTTP"` |  |
| rasa.rasa.livenessProbe.initialDelaySeconds | int | `30` |  |
| rasa.rasa.livenessProbe.periodSeconds | int | `15` |  |
| rasa.rasa.livenessProbe.successThreshold | int | `1` |  |
| rasa.rasa.livenessProbe.timeoutSeconds | int | `5` |  |
| rasa.rasa.overrideEnv[0].name | string | `"RASA_PRO_LICENSE"` |  |
| rasa.rasa.overrideEnv[0].valueFrom.secretKeyRef.key | string | `"RASA_PRO_LICENSE_SECRET_KEY"` |  |
| rasa.rasa.overrideEnv[0].valueFrom.secretKeyRef.name | string | `"studio-secrets"` |  |
| rasa.rasa.overrideEnv[1].name | string | `"OPENAI_API_KEY"` |  |
| rasa.rasa.overrideEnv[1].valueFrom.secretKeyRef.key | string | `"OPENAI_API_KEY_SECRET_KEY"` |  |
| rasa.rasa.overrideEnv[1].valueFrom.secretKeyRef.name | string | `"studio-secrets"` |  |
| rasa.rasa.persistence.create | bool | `true` |  |
| rasa.rasa.persistence.hostPath.enabled | bool | `false` |  |
| rasa.rasa.persistence.storageCapacity | string | `"1Gi"` |  |
| rasa.rasa.persistence.storageClassName | string | `nil` |  |
| rasa.rasa.persistence.storageRequests | string | `"1Gi"` |  |
| rasa.rasa.podSecurityContext.fsGroup | int | `1001` | User ID of the container to access the mounted volume |
| rasa.rasa.readinessProbe.enabled | bool | `true` |  |
| rasa.rasa.readinessProbe.failureThreshold | int | `6` |  |
| rasa.rasa.readinessProbe.httpGet.path | string | `"/"` |  |
| rasa.rasa.readinessProbe.httpGet.port | int | `8000` |  |
| rasa.rasa.readinessProbe.httpGet.scheme | string | `"HTTP"` |  |
| rasa.rasa.readinessProbe.initialDelaySeconds | int | `30` |  |
| rasa.rasa.readinessProbe.periodSeconds | int | `15` |  |
| rasa.rasa.readinessProbe.successThreshold | int | `1` |  |
| rasa.rasa.readinessProbe.timeoutSeconds | int | `5` |  |
| rasa.rasa.replicaCount | int | `1` |  |
| rasa.rasa.resources | object | `{}` | rasa.resources specifies the resources limits and requests |
| rasa.rasa.service.port | int | `80` |  |
| rasa.rasa.service.targetPort | int | `8000` |  |
| rasa.rasa.settings.mountDefaultConfigmap | bool | `false` |  |
| rasa.rasa.settings.useDefaultArgs | bool | `false` |  |
| rasa.rasaProServices.enabled | bool | `false` |  |
| replicated.enabled | bool | `false` |  |
| repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/studio/"` | repository specifies image repository for Studio |
| tag | string | `"1.10.0rc0"` | tag specifies image tag for Studio # Overrides the image tag whose default is the chart appVersion. |
| webClient.additionalContainers | list | `[]` | webClient.additionalContainers allows to specify additional containers for the deployment |
| webClient.affinity | object | `{}` | webClient.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| webClient.envFrom | list | `[]` | webClient.envFrom is used to add environment variables from ConfigMap or Secret |
| webClient.environmentVariables | object | `{"KEYCLOAK_CLIENT_ID":"rasa-studio-backend","KEYCLOAK_REALM":"rasa-studio"}` | webClient.environmentVariables defines environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| webClient.environmentVariables.KEYCLOAK_CLIENT_ID | string | `"rasa-studio-backend"` | Keycloak client id |
| webClient.environmentVariables.KEYCLOAK_REALM | string | `"rasa-studio"` | Keycloak realm name |
| webClient.image | object | `{"name":"studio-web-client","pullPolicy":"IfNotPresent"}` | Define image settings |
| webClient.image.name | string | `"studio-web-client"` | image.name specifies image repository |
| webClient.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| webClient.ingress | object | `{"annotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` | Configure the ingress resource that allows you to access the deployment installation. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| webClient.ingress.annotations | object | `{}` | ingress.annotations defines annotations to add to the ingress |
| webClient.ingress.className | string | `""` | ingress.className specifies the ingress className to be used |
| webClient.ingress.enabled | bool | `true` | ingress.enabled specifies whether an ingress service should be created |
| webClient.ingress.labels | object | `{}` | ingress.labels defines labels to add to the ingress |
| webClient.ingress.tls | list | `[]` | ingress.tls spefices the TLS configuration for ingress |
| webClient.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8080,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| webClient.nodeSelector | object | `{}` | webClient.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| webClient.podAnnotations | object | `{}` | webClient.podAnnotations defines annotations to add to the pod |
| webClient.podSecurityContext | object | `{"enabled":true}` | webClient.podSecurityContext defines pod security context |
| webClient.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8080,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| webClient.replicaCount | int | `1` | replicaCount specifies number of replicas |
| webClient.resources | object | `{}` | webClient.resources specifies the resources limits and requests |
| webClient.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | webClient.securityContext defines security context that allows you to overwrite the pod-level security context |
| webClient.service | object | `{"port":80,"targetPort":8080,"type":"ClusterIP"}` | Define service |
| webClient.service.port | int | `80` | service.port specifies service port |
| webClient.service.targetPort | int | `8080` | service.targetPort specifies service target port |
| webClient.service.type | string | `"ClusterIP"` | service.type specifies service type |
| webClient.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Define service account |
| webClient.serviceAccount.annotations | object | `{}` | serviceAccount.annotations defines annotations to add to the service account |
| webClient.serviceAccount.create | bool | `false` | serviceAccount.create specifies whether a service account should be created |
| webClient.serviceAccount.name | string | `""` | serviceAccount.name defines the name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| webClient.tolerations | list | `[]` | webClient.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
