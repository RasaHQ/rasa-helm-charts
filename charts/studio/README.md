# studio

This chart bootstraps Studio deployment on a Kubernetes cluster using the Helm package manager.

![Version: 1.1.2-rc](https://img.shields.io/badge/Version-1.1.2--rc-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 1.1.2-rc
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
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 1.1.2-rc
```

## General Configuration

- **imagePullSecrets**: If you're using a private Docker registry, provide the necessary credentials in this section.

> **Note:** For application specific settings, please refer to our [documentation](https://rasa.com/docs/) and bellow you can find the full list of values.

### Studio

To deploy Studio, set `studioEnabled: true`, `modelService.training.enabled: true`, and `modelService.running.enabled: true`. Configure image and image pull settings.

```yaml
studioEnabled: true
# Other settings...
modelService:
  training:
    enabled: true
    # Other settings...
  running:
    enabled: true
    # Other settings...
```

### MTS/MRS only

To deploy only MTS/MRS, set `studioEnabled: false`, with `modelService.training.enabled` and `modelService.running.enabled` to `true`.  Configure image and image pull settings.

```yaml
studioEnabled: false
# Other settings...
modelService:
  training:
    enabled: true
    # Other settings...
  running:
    enabled: true
    # Other settings...
```

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
| backend.environmentVariables | object | `{"DATABASE_URL":{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}},"DELETE_CONVERSATIONS_CRON_EXPRESSION":{"value":"0 * * * *"},"DELETE_CONVERSATIONS_OLDER_THAN_HOURS":{"value":""},"DOCKER_IMAGE_TAG":{"value":"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro:3.8.0"},"KEYCLOAK_API_CLIENT_ID":{"value":"admin-cli"},"KEYCLOAK_API_PASSWORD":{"secret":{"key":"KEYCLOAK_API_PASSWORD","name":"studio-secrets"}},"KEYCLOAK_API_USERNAME":{"value":"realmadmin"},"KEYCLOAK_REALM":{"value":"rasa-studio"},"RASA_CONFIG_FILE":{"value":""}}` | backend.environmentVariables defines environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| backend.environmentVariables.DATABASE_URL | object | `{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}}` | The URL of the database to connect to in the format postgresql://${database.username}:${database.password}@${database.host}:${database.port}/studio?schema=public |
| backend.environmentVariables.DELETE_CONVERSATIONS_CRON_EXPRESSION | object | `{"value":"0 * * * *"}` | https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax  ┌───────────── minute (0 - 59) | ┌───────────── hour (0 - 23) │ │ ┌───────────── day of the month (1 - 31) │ │ │ ┌───────────── month (1 - 12) │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday) │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ * * * * * |
| backend.environmentVariables.DELETE_CONVERSATIONS_OLDER_THAN_HOURS | object | `{"value":""}` | run if the "DELETE_CONVERSATIONS_OLDER_THAN_HOURS" value is left undefined. |
| backend.environmentVariables.DOCKER_IMAGE_TAG | object | `{"value":"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro:3.8.0"}` | The complete registry URL of the Rasa Plus docker image to be used for training |
| backend.environmentVariables.KEYCLOAK_API_PASSWORD | object | `{"secret":{"key":"KEYCLOAK_API_PASSWORD","name":"studio-secrets"}}` | These credentials are used by Studio Backend Server to communicate with Keycloak’s user management module |
| backend.environmentVariables.KEYCLOAK_API_USERNAME | object | `{"value":"realmadmin"}` | These credentials are used by Studio Backend Server to communicate with Keycloak’s user management module |
| backend.environmentVariables.RASA_CONFIG_FILE | object | `{"value":""}` | base64 encoded value of the Rasa Pro config.yml file. This is needed if you want to override the default config.yml file set by Studio. |
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
| config.database | object | `{"host":"","keycloakDatabaseName":"keycloak","modelServiceDatabaseName":"modelservice","password":{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"},"port":"5432","preferSSL":"true","rejectUnauthorized":"","username":""}` | The postgres database instance details for Studio to connect to. |
| config.database.host | string | `""` | The database host name |
| config.database.keycloakDatabaseName | string | `"keycloak"` | The database name for keycloak user management service |
| config.database.modelServiceDatabaseName | string | `"modelservice"` | The database name for model training and running service |
| config.database.password | object | `{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"}` | The database password |
| config.database.port | string | `"5432"` | The database port |
| config.database.preferSSL | string | `"true"` | Set to true if you want to use SSL for db connection |
| config.database.username | string | `""` | The database username |
| config.ingressHost | string | `"rasa.bot.com"` | Defines the host name for all the Studio ingress resources. Make sure you provide a valid host name. |
| config.keycloak.adminPassword | object | `{"secretKey":"KEYCLOAK_ADMIN_PASSWORD","secretName":"studio-secrets"}` | The admin password for Keycloak. This password is used to login to Keycloak admin console. |
| config.keycloak.adminUsername | string | `"kcadmin"` | The admin username for Keycloak. This username is used to login to Keycloak admin console. |
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
| modelService.gcpCredentials | object | `{"secretKey":null,"secretName":null}` | GCP credentials for the service account. The secretKey is the base64 encoded service account JSON. This is only required if you are using GCS for object storage. |
| modelService.gcpCredentials.secretKey | string | `nil` | gcpCredentials.secretName defines the Key in the secret ("studio-secrets") under which GCP service account JSON is stored |
| modelService.gcpCredentials.secretName | string | `nil` | gcpCredentials.secretName defines the name of the secret ("studio-secrets") that contains the GCP service account JSON |
| modelService.kafka.brokerAddress | string | `""` | kafka.brokerAddress is the URL:portNumber of the Kafka broker to which to connect to. For example "mykafka-88233-us1-kafka.upstash.io:9092" |
| modelService.kafka.saslMechanism | string | `""` | kafka.saslMechanism defines Kafka SASL mechanism used to connect to Kafka Broker. # Values: PLAIN, SCRAM-SHA-256, SCRAM-SHA-512. You can leave this empty if you are not using SASL. |
| modelService.kafka.saslPassword | object | `{"secretKey":"KAFKA_SASL_PASSWORD","secretName":"studio-secrets"}` | kafka.saslPassword is a password used to connect to Kafka broker which has SASL authentication method enabled. |
| modelService.kafka.saslUsername | string | `""` | kafka.saslUsername is a username used to connect to Kafka broker which has SASL authentication method enabled. |
| modelService.kafka.securityProtocol | string | `""` | kafka.securityProtocol defines security protocol used to connect to Kafka broker. # Values: PLAINTEXT, SASL_PLAINTEXT, SSL, SASL_SSL |
| modelService.kafka.sslCaLocation | string | `""` | kafka.sslCaLocation defines location from which CA certs should be read. Used when SSL security is enabled (SSL, SASL_SSL). |
| modelService.openAiKey.secretKey | string | `"OPENAI_API_KEY_SECRET_KEY"` | openAiKey.secretKey defines the Key in the K8s under which OpenAI API key is stored in K8s secret. |
| modelService.openAiKey.secretName | string | `"studio-secrets"` | openAiKey.secretName defines the name of the secret under which OpenAI API key is stored. |
| modelService.persistence.aws | bool | `true` | If you are deploying to AWS and using EFS for volume, set this value to true. |
| modelService.persistence.create | bool | `true` | Should the PV and PVC be created |
| modelService.persistence.efs_id | string | `""` | FileSystemId::MountPoint of the AWS EFS volume. For example "fs-0bbaea252301ca2d4::fsap-0b4550cc4c77377fd" |
| modelService.persistence.hostPath | string | `""` | Directory from the host machine that will be mounted to the container for training data. This value is used only when type is set to local |
| modelService.persistence.localNodeName | string | `""` | Node on which the PV will be created This value is used only when type is set to local |
| modelService.persistence.nfsServer | string | `""` | DNS name or IP address of the NFS server. This value is used only when type is set to nfs |
| modelService.persistence.storageCapacity | string | `"1Gi"` | Storage Capacity for PV |
| modelService.persistence.storageClassName | string | `"standard-rwo"` | Storage Class name for PV. Should be `efs-sc` if you are using AWS EFS. It's "standard-rwo" if you are using NFS server. |
| modelService.persistence.storageRequests | string | `"1Gi"` | Storage requests for PVC |
| modelService.persistence.type | string | `""` | Type of the volume that will be used to store the training data Valid values: local, nfs. Leave this empty if you are using AWS EFS. |
| modelService.rasaProLicense.secretKey | string | `"RASA_PRO_LICENSE_SECRET_KEY"` | rasaProLicense.secretKey defines the key in the K8s under which Rasa Pro License is stored. |
| modelService.rasaProLicense.secretName | string | `"studio-secrets"` | rasaProLicense.secretName defines the name of the secret under which Rasa Pro License is stored. |
| modelService.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/model-training-and-running-services/"` | repository specifies image repository for Studio |
| modelService.running.consumer.additionalContainers | list | `[]` | consumer.additionalContainers allows to specify additional containers for the deployment |
| modelService.running.consumer.affinity | object | `{}` | consumer.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| modelService.running.consumer.envFrom | list | `[]` | consumer.envFrom is used to add environment variables from ConfigMap or Secret |
| modelService.running.consumer.environmentVariables | object | `{"DEPLOYMENT_JOB_KAFKA_TOPIC":{"value":"deployment-job"},"KAFKA_DEPLOYMENT_RESULT_TOPIC":{"value":"deployment-result"},"KUBERNETES_BASE_BOT_DATA_PATH":{"value":"/home"},"KUBERNETES_JOB_BOT_CONFIG_MOUNT":{"value":"/app"},"MODEL_DEPLOYMENT_KAFKA_CONSUMER_ID":{"value":"deployment-result-consumer-group"},"RASA_DEBUG_LOGS":{"value":"false"},"RASA_LIMITS_CPU":{"value":"2500m"},"RASA_LIMITS_MEMORY":{"value":"2.5Gi"},"RASA_REQUESTS_CPU":{"value":"1000m"},"RASA_REQUESTS_MEMORY":{"value":"1Gi"}}` | consumer.environmentVariables defines environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| modelService.running.consumer.environmentVariables.DEPLOYMENT_JOB_KAFKA_TOPIC | object | `{"value":"deployment-job"}` | Kafka topic for internal service communication. Please make sure to pre-create this topic. |
| modelService.running.consumer.environmentVariables.KAFKA_DEPLOYMENT_RESULT_TOPIC | object | `{"value":"deployment-result"}` | Kafka topic for internal service communication. Please make sure to pre-create this topic. |
| modelService.running.consumer.environmentVariables.RASA_DEBUG_LOGS | object | `{"value":"false"}` | Set this to true if you want to include rasa debug logs during model running |
| modelService.running.consumer.environmentVariables.RASA_LIMITS_CPU | object | `{"value":"2500m"}` | Value of CPU limit to allocate to the container for model training |
| modelService.running.consumer.environmentVariables.RASA_LIMITS_MEMORY | object | `{"value":"2.5Gi"}` | Value of Memory limit to allocate to the container for model training |
| modelService.running.consumer.environmentVariables.RASA_REQUESTS_MEMORY | object | `{"value":"1Gi"}` | Value of Memory limit to allocate to the container for model training |
| modelService.running.consumer.image.name | string | `"model-running-job-consumer"` | Specifies image name |
| modelService.running.consumer.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| modelService.running.consumer.nodeSelector | object | `{}` | consumer.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| modelService.running.consumer.podAnnotations | object | `{}` | consumer.annotations defines annotations to add to the pod |
| modelService.running.consumer.podSecurityContext | object | `{"enabled":true}` | consumer.podSecurityContext defines pod security context |
| modelService.running.consumer.rasaReadinessProbe.failureThreshold | int | `50` | rasaReadinessProbe.failureThreshold is allowed number of failed readiness checks until Rasa container inside the pod is considered unreachable and unable to serve requests. # Total possible readiness check = initial delay + check interval x failure threshold |
| modelService.running.consumer.rasaReadinessProbe.initialDelaySeconds | int | `10` | rasaReadinessProbe.initialDelaySeconds is initial delay after which readiness probe will be run on the container which is running Rasa deployment. # Readiness check assess if Rasa is ready to serve requests. |
| modelService.running.consumer.rasaReadinessProbe.intervalInSeconds | int | `5` | rasaReadinessProbe.intervalInSeconds interval (in seconds) on which readiness check will be performed. |
| modelService.running.consumer.rasaStartupProbe.failureThreshold | int | `50` | rasaStartupProbe.failureThreshold is allowed number of failed startup checks until Rasa app inside the container is considered not started. # Total possible startup check = initial delay + check interval x failure threshold |
| modelService.running.consumer.rasaStartupProbe.initialDelaySeconds | int | `10` | rasaStartupProbe.initialDelaySeconds is initial delay after which startup probe will be run on the container which is running Rasa deployment. # Readiness check assess if Rasa application is ready. |
| modelService.running.consumer.rasaStartupProbe.intervalInSeconds | int | `5` | rasaStartupProbe.intervalInSeconds is interval (in seconds) on which startup check will be performed. |
| modelService.running.consumer.replicaCount | int | `2` | consumer.replicaCount specifies number of replicas |
| modelService.running.consumer.resources | object | `{}` | consumer.resources specifies the resources limits and requests |
| modelService.running.consumer.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | consumer.securityContext defines security context that allows you to overwrite the pod-level security context |
| modelService.running.consumer.tolerations | list | `[]` | consumer.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| modelService.running.consumer.volumeMounts | list | `[]` | consumer.volumeMounts specifies additional volumes to mount |
| modelService.running.consumer.volumes | list | `[]` | consumer.volumes specifies additional volumes # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| modelService.running.enabled | bool | `true` |  |
| modelService.running.orchestrator.additionalContainers | list | `[]` | orchestrator.additionalContainers allows to specify additional containers for the deployment |
| modelService.running.orchestrator.affinity | object | `{}` | orchestrator.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| modelService.running.orchestrator.envFrom | list | `[]` | orchestrator.envFrom is used to add environment variables from ConfigMap or Secret |
| modelService.running.orchestrator.environmentVariables | object | `{"DEPLOYMENT_JOB_TOPIC":{"value":"deployment-job"},"DEPLOYMENT_RESULT_CONSUMER_GROUP_ID":{"value":"deployment-result-consumer-group"},"DEPLOYMENT_RESULT_TOPIC":{"value":"deployment-result"}}` | orchestrator.environmentVariables defines environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| modelService.running.orchestrator.environmentVariables.DEPLOYMENT_JOB_TOPIC | object | `{"value":"deployment-job"}` | Kafka topic for internal service communication. Please make sure to pre-create this topic. |
| modelService.running.orchestrator.environmentVariables.DEPLOYMENT_RESULT_TOPIC | object | `{"value":"deployment-result"}` | Kafka topic for internal service communication. Please make sure to pre-create this topic. |
| modelService.running.orchestrator.image.name | string | `"model-running-orchestrator"` | Specifies image name |
| modelService.running.orchestrator.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| modelService.running.orchestrator.ingress | object | `{"annotations":{},"className":"","enabled":true,"hosts":[{"extraPaths":[],"host":null}],"labels":{},"tls":[]}` | orchestrator.ingress configures the ingress resource. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| modelService.running.orchestrator.ingress.annotations | object | `{}` | ingress.annotations defines annotations to add to the ingress |
| modelService.running.orchestrator.ingress.className | string | `""` | ingress.className specifies the ingress className to be used |
| modelService.running.orchestrator.ingress.enabled | bool | `true` | ingress.enabled specifies whether an ingress service should be created |
| modelService.running.orchestrator.ingress.hosts | list | `[{"extraPaths":[],"host":null}]` | Specifies additional hosts for this ingress. Additional hosts are NOT required since a default host is added automatically. |
| modelService.running.orchestrator.ingress.labels | object | `{}` | ingress.labels defines labels to add to the ingress |
| modelService.running.orchestrator.ingress.tls | list | `[]` | Spefices the TLS configuration for ingress |
| modelService.running.orchestrator.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8001,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| modelService.running.orchestrator.nodeSelector | object | `{}` | orchestrator.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| modelService.running.orchestrator.podAnnotations | object | `{}` | orchestrator.podAnnotations defines annotations to add to the pod |
| modelService.running.orchestrator.podSecurityContext | object | `{"enabled":true}` | orchestrator.podSecurityContext defines pod security context |
| modelService.running.orchestrator.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8001,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| modelService.running.orchestrator.replicaCount | int | `1` | orchestrator.replicaCount specifies number of replicas |
| modelService.running.orchestrator.resources | object | `{}` | orchestrator.resources specifies the resources limits and requests |
| modelService.running.orchestrator.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | orchestrator.securityContext defines security context that allows you to overwrite the pod-level security context |
| modelService.running.orchestrator.service | object | `{"port":8001,"targetPort":8001,"type":"ClusterIP"}` | Define service |
| modelService.running.orchestrator.service.port | int | `8001` | service.port specifies service port |
| modelService.running.orchestrator.service.targetPort | int | `8001` | service.targetPort specifies service target port |
| modelService.running.orchestrator.service.type | string | `"ClusterIP"` | service.type specifies service type # Use `NodePort` if using GCP ingress controller, in ALL other cases keep `ClusterIP`. |
| modelService.running.orchestrator.tolerations | list | `[]` | orchestrator.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| modelService.running.orchestrator.volumeMounts | string | `nil` | orchestrator.volumeMounts specifies additional volumes to mount |
| modelService.running.orchestrator.volumes | list | `[]` | orchestrator.volumes specifies additional volumes # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| modelService.running.proxy.botTalkSubPath | string | `"/talk"` |  |
| modelService.running.proxy.image | string | `"europe-west3-docker.pkg.dev/rasa-releases/model-training-and-running-services/nginx-unprivileged:1.27-alpine"` | proxy.image defines image settings |
| modelService.running.proxy.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/healthz","port":8080,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| modelService.running.proxy.podAnnotations | object | `{}` | proxy.podAnnotations defines annotations to add to the pod |
| modelService.running.proxy.podSecurityContext | object | `{"enabled":true}` | proxy.podSecurityContext defines pod security context |
| modelService.running.proxy.pullPolicy | string | `"IfNotPresent"` | proxy.pullPolicy specifies image pull policy |
| modelService.running.proxy.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/healthz","port":8080,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| modelService.running.proxy.replicaCount | int | `1` | proxy.replicaCount specifies number of replicas |
| modelService.running.proxy.resources | object | `{}` | proxy.resources specifies the resources limits and requests |
| modelService.running.proxy.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | proxy.securityContext defines security context that allows you to overwrite the pod-level security context |
| modelService.running.proxy.service | object | `{"port":80,"targetPort":8080,"type":"ClusterIP"}` | Define service |
| modelService.running.proxy.service.port | int | `80` | service.port specifies service port |
| modelService.running.proxy.service.targetPort | int | `8080` | service.targetPort specifies service target port |
| modelService.running.proxy.service.type | string | `"ClusterIP"` | service.type specifies service type |
| modelService.running.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Define service account |
| modelService.running.serviceAccount.annotations | object | `{}` | serviceAccount.annotations defines annotations to add to the service account |
| modelService.running.serviceAccount.create | bool | `true` | serviceAccount.create specifies whether a service account should be created |
| modelService.running.serviceAccount.name | string | `""` | serviceAccount.name defines the name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| modelService.runsInCluster | bool | `true` | modelService.runsInCluster describes if service is run inside cluster or not. # It is used during the initialization procedure or API clients which communicate with K8S API. |
| modelService.storage.bucketName | string | `""` | Name of the storage bucket. Make sure to pre-create this bucket. |
| modelService.storage.cloudskdComputeZone | string | `""` | Needed if STORAGE_TYPE is set to gcs. The zone where the bucket is located. |
| modelService.storage.googleCloudProject | string | `""` | Needed if STORAGE_TYPE is set to gcs. The project ID of the GCP project. |
| modelService.storage.regionName | string | `""` | Needed if STORAGE_TYPE is set to aws_s3. The region where the bucket is located. |
| modelService.storage.storageServiceAccount | object | `{"secretKey":"STORAGE_SIGNED_URL_SERVICE_ACCOUNT","secretName":"studio-secrets"}` | Needed if STORAGE_TYPE is set to gcs. The service account email address. |
| modelService.storage.type | string | `""` | use "gcs" for Google Cloud Storage, "aws_s3" for AWS S3 |
| modelService.tag | string | `"3.3.2"` | tag specifies image tag for Studio |
| modelService.training.consumer.additionalContainers | list | `[]` | consumer.additionalContainers allows to specify additional containers for the deployment |
| modelService.training.consumer.affinity | object | `{}` | consumer.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| modelService.training.consumer.envFrom | list | `[]` | consumer.envFrom is used to add environment variables from ConfigMap or Secret |
| modelService.training.consumer.environmentVariables | object | `{"KAFKA_JOB_TOPIC":{"value":"training-job"},"KAFKA_RESULT_TOPIC":{"value":"training-result"},"KUBERNETES_BASE_TRAINING_DATA_PATH":{"value":"/home"},"KUBERNETES_JOB_BOT_CONFIG_MOUNT":{"value":"/app"},"MODEL_TRAINING_KAFKA_CONSUMER_ID":{"value":"training-result-consumer-group"},"RASA_DEBUG_LOGS":{"value":"false"},"RASA_LIMITS_CPU":{"value":"2500m"},"RASA_LIMITS_MEMORY":{"value":"2.5Gi"},"RASA_REQUESTS_CPU":{"value":"1000m"},"RASA_REQUESTS_MEMORY":{"value":"1Gi"}}` | consumer.environmentVariables defines environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| modelService.training.consumer.environmentVariables.KAFKA_JOB_TOPIC | object | `{"value":"training-job"}` | Kafka topic for internal service communication. Please make sure to pre-create this topic. |
| modelService.training.consumer.environmentVariables.KAFKA_RESULT_TOPIC | object | `{"value":"training-result"}` | Kafka topic for internal service communication. Please make sure to pre-create this topic. |
| modelService.training.consumer.environmentVariables.RASA_DEBUG_LOGS | object | `{"value":"false"}` | Set this to true if you want to include rasa debug logs during model training |
| modelService.training.consumer.environmentVariables.RASA_LIMITS_CPU | object | `{"value":"2500m"}` | Value of CPU limit to allocate to the container for model training |
| modelService.training.consumer.environmentVariables.RASA_LIMITS_MEMORY | object | `{"value":"2.5Gi"}` | Value of Memory limit to allocate to the container for model training |
| modelService.training.consumer.environmentVariables.RASA_REQUESTS_CPU | object | `{"value":"1000m"}` | Value of CPU limit to allocate to the container for model training |
| modelService.training.consumer.environmentVariables.RASA_REQUESTS_MEMORY | object | `{"value":"1Gi"}` | Value of Memory limit to allocate to the container for model training |
| modelService.training.consumer.image.name | string | `"model-training-job-consumer"` |  |
| modelService.training.consumer.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| modelService.training.consumer.nodeSelector | object | `{}` | consumer.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| modelService.training.consumer.podAnnotations | object | `{}` | consumer.annotations defines annotations to add to the pod |
| modelService.training.consumer.podSecurityContext | object | `{"enabled":true}` | consumer.podSecurityContext defines pod security context |
| modelService.training.consumer.replicaCount | int | `1` | consumer.replicaCount specifies number of replicas |
| modelService.training.consumer.resources | object | `{}` | consumer.resources specifies the resources limits and requests |
| modelService.training.consumer.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | consumer.securityContext defines security context that allows you to overwrite the pod-level security context |
| modelService.training.consumer.tolerations | list | `[]` | consumer.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| modelService.training.consumer.volumeMounts | list | `[]` | consumer.volumeMounts specifies additional volumes to mount |
| modelService.training.consumer.volumes | list | `[]` | consumer.volumes specifies additional volumes # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| modelService.training.enabled | bool | `true` |  |
| modelService.training.orchestrator.additionalContainers | list | `[]` | orchestrator.additionalContainers allows to specify additional containers for the deployment |
| modelService.training.orchestrator.affinity | object | `{}` | orchestrator.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| modelService.training.orchestrator.envFrom | list | `[]` | orchestrator.envFrom is used to add environment variables from ConfigMap or Secret |
| modelService.training.orchestrator.environmentVariables | object | `{"KAFKA_TRAINING_STATUS_UPDATE_TOPIC":{"value":"training-status-update"},"TRAINING_JOB_TOPIC":{"value":"training-job"},"TRAINING_RESULT_CONSUMER_GROUP_ID":{"value":"training-result-consumer-group"},"TRAINING_RESULT_TOPIC":{"value":"training-result"}}` | orchestrator.environmentVariables defines environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| modelService.training.orchestrator.environmentVariables.KAFKA_TRAINING_STATUS_UPDATE_TOPIC | object | `{"value":"training-status-update"}` | Kafka topic for internal service communication. Please make sure to pre-create this topic. |
| modelService.training.orchestrator.environmentVariables.TRAINING_JOB_TOPIC | object | `{"value":"training-job"}` | Kafka topic for internal service communication. Please make sure to pre-create this topic. |
| modelService.training.orchestrator.environmentVariables.TRAINING_RESULT_TOPIC | object | `{"value":"training-result"}` | Kafka topic for internal service communication. Please make sure to pre-create this topic. |
| modelService.training.orchestrator.image.name | string | `"model-training-orchestrator"` | Specifies image name |
| modelService.training.orchestrator.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| modelService.training.orchestrator.ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}],"labels":{},"tls":[]}` | orchestrator.ingress configures the ingress resource. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| modelService.training.orchestrator.ingress.annotations | object | `{}` | ingress.annotations defines annotations to add to the ingress |
| modelService.training.orchestrator.ingress.className | string | `""` | ingress.className specifies the ingress className to be used |
| modelService.training.orchestrator.ingress.enabled | bool | `false` | Specifies whether an ingress service should be created. An ingress for this service is not mandatory. |
| modelService.training.orchestrator.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | ingress.hosts specifies the hosts for this ingress |
| modelService.training.orchestrator.ingress.labels | object | `{}` | ingress.labels defines labels to add to the ingress |
| modelService.training.orchestrator.ingress.tls | list | `[]` | ingress.tls spefices the TLS configuration for ingress |
| modelService.training.orchestrator.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| modelService.training.orchestrator.nodeSelector | object | `{}` | orchestrator.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| modelService.training.orchestrator.podAnnotations | object | `{}` | orchestrator.podAnnotations defines annotations to add to the pod |
| modelService.training.orchestrator.podSecurityContext | object | `{"enabled":true}` | orchestrator.podSecurityContext defines pod security context |
| modelService.training.orchestrator.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| modelService.training.orchestrator.replicaCount | int | `1` | orchestrator.replicaCount specifies number of replicas |
| modelService.training.orchestrator.resources | object | `{}` | orchestrator.resources specifies the resources limits and requests |
| modelService.training.orchestrator.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | orchestrator.securityContext defines security context that allows you to overwrite the pod-level security context |
| modelService.training.orchestrator.service | object | `{"port":8000,"targetPort":8000,"type":"ClusterIP"}` | Define service |
| modelService.training.orchestrator.service.port | int | `8000` | service.port specifies service port |
| modelService.training.orchestrator.service.targetPort | int | `8000` | service.targetPort specifies service target port |
| modelService.training.orchestrator.service.type | string | `"ClusterIP"` | service.type specifies service type # Use `NodePort` if using GCP ingress controller, in ALL other cases keep `ClusterIP`. |
| modelService.training.orchestrator.tolerations | list | `[]` | orchestrator.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| modelService.training.orchestrator.volumeMounts | string | `nil` | orchestrator.volumeMounts specifies additional volumes to mount |
| modelService.training.orchestrator.volumes | string | `nil` | orchestrator.volumes specifies additional volumes # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| modelService.training.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Define service account |
| modelService.training.serviceAccount.annotations | object | `{}` | serviceAccount.annotations defines annotations to add to the service account |
| modelService.training.serviceAccount.create | bool | `true` | serviceAccount.create specifies whether a service account should be created |
| modelService.training.serviceAccount.name | string | `""` | serviceAccount.name defines the name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| nameOverride | string | `""` | Override name of app |
| networkPolicy.denyAll | bool | `false` | networkPolicy.denyAll defines whether to apply denyAll network policy |
| networkPolicy.enabled | bool | `false` | networkPolicy.enabled specifies whether to enable network policies |
| networkPolicy.nodeCIDR | list | `[]` | networkPolicy.nodeCIDR allows for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes |
| podLabels | object | `{}` | podLabels defines labels to add to all Studio pod(s) |
| replicated.enabled | bool | `false` |  |
| repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/studio/"` | repository specifies image repository for Studio |
| studioEnabled | bool | `true` | studioEnabled defines if Studio will be deployed # Disable this in case you only want to deploy MTS/MRS |
| tag | string | `"1.5.0"` | tag specifies image tag for Studio # Overrides the image tag whose default is the chart appVersion. |
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
