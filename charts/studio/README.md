# studio

This chart bootstraps Studio deployment on a Kubernetes cluster using the Helm package manager.

![Version: 0.2.2](https://img.shields.io/badge/Version-0.2.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 0.2.2
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
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 0.2.2
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
| backend.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| backend.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Specifies the HPA settings |
| backend.autoscaling.enabled | bool | `false` | Specifies whether autoscaling should be enabled |
| backend.autoscaling.maxReplicas | int | `100` | Specifies the maximum number of replicas |
| backend.autoscaling.minReplicas | int | `1` | Specifies the minimum number of replicas |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the target CPU/Memory utilization percentage |
| backend.envFrom | list | `[]` | backend.envFrom is used to add environment variables from ConfigMap or Secret |
| backend.environmentVariables | object | `{"DATABASE_URL":{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}},"KEYCLOAK_API_CLIENT_ID":{"value":"admin-cli"},"KEYCLOAK_API_GRANT_TYPE":{"value":"password"},"KEYCLOAK_API_PASSWORD":{"secret":{"key":"KEYCLOAK_API_PASSWORD","name":"studio-secrets"}},"KEYCLOAK_API_USERNAME":{"value":""},"KEYCLOAK_REALM":{"value":"rasa-local-dev"},"KEYCLOAK_URL":{"value":""}}` | Define environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| backend.image | object | `{"name":"studio-backend","pullPolicy":"IfNotPresent"}` | Define image settings |
| backend.image.name | string | `"studio-backend"` | Specifies image repository |
| backend.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| backend.ingress | object | `{"annotations":{},"className":"","enabled":true,"hosts":[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}],"labels":{},"tls":[]}` | Configure the ingress resource that allows you to access the deployment installation. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| backend.ingress.annotations | object | `{}` | Annotations to add to the ingress |
| backend.ingress.className | string | `""` | Specifies the ingress className to be used |
| backend.ingress.enabled | bool | `true` | Specifies whether an ingress service should be created |
| backend.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}]` | Specifies the hosts for this ingress |
| backend.ingress.labels | object | `{}` | Labels to add to the ingress |
| backend.ingress.tls | list | `[]` | Spefices the TLS configuration for ingress |
| backend.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| backend.migration | object | `{"enable":true,"image":{"name":"studio-database-migration","pullPolicy":"IfNotPresent"}}` | Define Studio Database Migration job settings |
| backend.migration.enable | bool | `true` | Specifies whether a database migration job should be created |
| backend.migration.image | object | `{"name":"studio-database-migration","pullPolicy":"IfNotPresent"}` | Specifies which image database migration job should use |
| backend.migration.image.name | string | `"studio-database-migration"` | Specifies the repository of the image |
| backend.migration.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| backend.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| backend.podAnnotations | object | `{}` | Annotations to add to the pod |
| backend.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| backend.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| backend.replicaCount | int | `1` | Specifies number of replicas |
| backend.resources | object | `{}` | Specifies the resources limits and requests |
| backend.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| backend.service | object | `{"port":80,"targetPort":4000,"type":"ClusterIP"}` | Define service |
| backend.service.port | int | `80` | Specify service port |
| backend.service.targetPort | int | `4000` | Specify service target port |
| backend.service.type | string | `"ClusterIP"` | Specify service type |
| backend.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Define service account |
| backend.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| backend.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| backend.serviceAccount.name | string | `""` | The name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| backend.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| deploymentAnnotations | object | `{}` | deploymentAnnotations defines annotations to add to all Studio deployments |
| deploymentLabels | object | `{}` | deploymentLabels defines labels to add to all Studio deployment |
| dnsConfig | object | `{}` | Specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | Specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| eventIngestion.additionalContainers | list | `[]` | eventIngestion.additionalContainers allows to specify additional containers for the deployment |
| eventIngestion.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| eventIngestion.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Specifies the HPA settings |
| eventIngestion.autoscaling.enabled | bool | `false` | Specifies whether autoscaling should be enabled |
| eventIngestion.autoscaling.maxReplicas | int | `100` | Specifies the maximum number of replicas |
| eventIngestion.autoscaling.minReplicas | int | `1` | Specifies the minimum number of replicas |
| eventIngestion.autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the target CPU/Memory utilization percentage |
| eventIngestion.envFrom | list | `[]` | eventIngestion.envFrom is used to add environment variables from ConfigMap or Secret |
| eventIngestion.environmentVariables | object | `{"DATABASE_URL":{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}},"KAFKA_BROKER_ADDRESS":{"value":""},"KAFKA_CA_FILE":{"value":""},"KAFKA_CERT_FILE":{"value":""},"KAFKA_CLIENT_ID":{"value":"kafka-python-rasa"},"KAFKA_CUSTOM_SSL":{"value":""},"KAFKA_DLQ_TOPIC":{"value":""},"KAFKA_ENABLE_SSL":{"value":""},"KAFKA_GROUP_ID":{"value":""},"KAFKA_KEY_FILE":{"value":""},"KAFKA_REJECT_UNAUTHORIZED":{"value":""},"KAFKA_SASL_MECHANISM":{"value":""},"KAFKA_SASL_PASSWORD":{"secret":{"key":"KAFKA_SASL_PASSWORD","name":"studio-secrets"}},"KAFKA_SASL_USERNAME":{"value":""},"KAFKA_TOPIC":{"value":""},"NODE_TLS_REJECT_UNAUTHORIZED":{"value":""}}` | Define environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| eventIngestion.image | object | `{"name":"studio-event-ingestion","pullPolicy":"IfNotPresent"}` | Define image settings |
| eventIngestion.image.name | string | `"studio-event-ingestion"` | Specifies image repository |
| eventIngestion.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| eventIngestion.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| eventIngestion.podAnnotations | object | `{}` | Annotations to add to the pod |
| eventIngestion.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| eventIngestion.replicaCount | int | `1` | Specifies number of replicas |
| eventIngestion.resources | object | `{}` | Specifies the resources limits and requests |
| eventIngestion.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| eventIngestion.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Define service account |
| eventIngestion.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| eventIngestion.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| eventIngestion.serviceAccount.name | string | `""` | The name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| eventIngestion.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| eventIngestion.volumeMounts | list | `[]` | eventIngestion.volumeMounts specifies additional volumes to mount in the Studio event ingestion container |
| eventIngestion.volumes | list | `[]` | eventIngestion.volumes specify additional volumes for the Studio event ingestion container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| fullnameOverride | string | `""` | Override the full qualified app name |
| global.additionalDeploymentLabels | object | `{}` | additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| hostNetwork | bool | `false` | Controls whether the pod may use the node network namespace |
| imagePullSecrets | list | `[]` | Repository pull secrets |
| keycloak.additionalContainers | list | `[]` | keycloak.additionalContainers allows to specify additional containers for the deployment |
| keycloak.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| keycloak.envFrom | list | `[]` | keycloak.envFrom is used to add environment variables from ConfigMap or Secret |
| keycloak.environmentVariables | object | `{"KC_DB_PASSWORD":{"secret":{"key":"KC_DB_PASSWORD","name":"studio-secrets"}},"KC_DB_SSL":{"value":""},"KC_DB_URL":{"value":""},"KC_DB_USERNAME":{"value":""},"KC_PROXY":{"value":""},"KC_REJECT_UNAUTHORIZED":{"value":""},"KEYCLOAK_ADMIN":{"value":""},"KEYCLOAK_ADMIN_PASSWORD":{"secret":{"key":"KEYCLOAK_ADMIN_PASSWORD","name":"studio-secrets"}}}` | Define environment variables for deployment |
| keycloak.image | object | `{"name":"studio-keycloak","pullPolicy":"IfNotPresent"}` | Define image settings |
| keycloak.image.name | string | `"studio-keycloak"` | Specifies image repository |
| keycloak.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| keycloak.ingress | object | `{"annotations":{},"className":"","enabled":true,"hosts":[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/auth","pathType":"Prefix"}]}],"labels":{},"tls":[]}` | Configure the ingress resource that allows you to access the deployment installation. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| keycloak.ingress.annotations | object | `{}` | Annotations to add to the ingress |
| keycloak.ingress.className | string | `""` | Specifies the ingress className to be used |
| keycloak.ingress.enabled | bool | `true` | Specifies whether an ingress service should be created |
| keycloak.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/auth","pathType":"Prefix"}]}]` | Specifies the hosts for this ingress |
| keycloak.ingress.labels | object | `{}` | Labels to add to the ingress |
| keycloak.ingress.tls | list | `[]` | Spefices the TLS configuration for ingress |
| keycloak.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/auth","port":8080,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| keycloak.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| keycloak.podAnnotations | object | `{}` | Annotations to add to the pod |
| keycloak.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| keycloak.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/auth","port":8080,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| keycloak.replicaCount | int | `1` | Specifies number of replicas |
| keycloak.resources | object | `{}` | Specifies the resources limits and requests |
| keycloak.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| keycloak.service | object | `{"port":80,"targetPort":8080,"type":"ClusterIP"}` | Define service |
| keycloak.service.port | int | `80` | Specify service port |
| keycloak.service.type | string | `"ClusterIP"` | Specify service type |
| keycloak.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Define service account |
| keycloak.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| keycloak.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| keycloak.serviceAccount.name | string | `""` | The name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| keycloak.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| modelService.gcpCredentials | object | `{"secretKey":"GCP_CREDS","secretName":"studio-secrets"}` | GCP credentials for the service account |
| modelService.kafka.brokerAddress | string | `""` | URL of the Kafka broker to which to connect to. |
| modelService.kafka.saslMechanism | string | `"SCRAM-SHA-256"` | Kafka SASL mechanism used to connect to Kafka Broker. # Values: PLAIN, SCRAM-SHA-256, SCRAM-SHA-512 |
| modelService.kafka.saslPassword | object | `{"secretKey":"KAFKA_SASL_PASSWORD","secretName":"studio-secrets"}` | Password used to connect to Kafka broker which has SASL authentication method enabled. |
| modelService.kafka.saslUsername | string | `""` | Username used to connect to Kafka broker which has SASL authentication method enabled. |
| modelService.kafka.securityProtocol | string | `"SASL_SSL"` | Security protocol used to connect to Kafka broker. # Values: PLAINTEXT, SASL_PLAINTEXT, SSL, SASL_SSL |
| modelService.kafka.sslCaLocation | string | `""` | Location from which CA certs should be read. Used when SSL security is enabled (SSL, SASL_SSL). |
| modelService.keycloak.clientId | string | `""` | Client ID used to authenticate with Keycloak. |
| modelService.keycloak.clientSecret | object | `{"secretKey":"KEYCLOAK_CLIENT_SECRET","secretName":"studio-secrets"}` | Secret used to authenticate with Keycloak. |
| modelService.keycloak.enableAuthorization | bool | `false` |  |
| modelService.keycloak.enabled | bool | `false` | Enable or disable Keycloack |
| modelService.keycloak.realmName | string | `""` |  |
| modelService.keycloak.serverUrl | string | `""` | URL on which Keycloak server is available. If this variable is not set, authorization will be disabled. |
| modelService.openAiKey.secretKey | string | `"OPENAI_API_KEY_SECRET_KEY"` | Key in the K8s under which OpenAI API key is stored in K8s secret. |
| modelService.openAiKey.secretName | string | `"studio-secrets"` | Set this to the name of the secret under which OpenAI API key is stored. |
| modelService.persistence.aws | bool | `true` | If you are deploying to AWS and using EFS for volume, set this value to true. |
| modelService.persistence.create | bool | `true` | Should the PV and PVC be created It is good practice to create volumes once and then reuse them. So set this value to true only when you are deploying the service for the first time. If you are redeploying the service, set this value to false. |
| modelService.persistence.efs_id | string | `""` | FileSystemId of the AWS EFS volume |
| modelService.persistence.hostPath | string | `""` | Directory from the host machine that will be mounted to the container for training data This value is used only when type is set to local |
| modelService.persistence.localNodeName | string | `""` | Node on which the PV will be created This value is used only when type is set to local |
| modelService.persistence.nfsServer | string | `""` | DNS name or IP address of the NFS server This value is used only when type is set to nfs |
| modelService.persistence.storageCapacity | string | `"1Gi"` | Storage Capacity for PV |
| modelService.persistence.storageClassName | string | `""` | Storage Class name for PV |
| modelService.persistence.storageRequests | string | `"1Gi"` | Storage requests for PVC |
| modelService.persistence.type | string | `"local"` | Type of the volume that will be used to store the training data Valid values: local, nfs |
| modelService.rasaProLicense.secretKey | string | `"RASA_PRO_LICENSE_SECRET_KEY"` | Key in the K8s under which Rasa Pro License is stored. |
| modelService.rasaProLicense.secretName | string | `"studio-secrets"` | Set this to the name of the secret under which Rasa Pro License is stored. |
| modelService.running.consumer.additionalContainers | list | `[]` | Allows to specify additional containers for the deployment |
| modelService.running.consumer.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| modelService.running.consumer.envFrom | list | `[]` | envFrom is used to add environment variables from ConfigMap or Secret |
| modelService.running.consumer.environmentVariables | object | `{"CLOUDSDK_COMPUTE_ZONE":{"value":""},"DEPLOYMENT_JOB_KAFKA_TOPIC":{"value":""},"DEPLOYMENT_STORAGE_SIGNED_URL_SERVICE_ACCOUNT":{"secret":{"key":"TRAINING_STORAGE_SIGNED_URL_SERVICE_ACCOUNT","name":"studio-secrets"}},"GCS_BUCKET_NAME":{"value":""},"GOOGLE_CLOUD_PROJECT":{"value":""},"KAFKA_DEPLOYMENT_RESULT_TOPIC":{"value":""},"KUBERNETES_BASE_BOT_DATA_PATH":{"value":"/home"},"KUBERNETES_JOB_BOT_CONFIG_MOUNT":{"value":"/app"},"MODEL_DEPLOYMENT_KAFKA_CONSUMER_ID":{"value":""},"STORAGE_TYPE":{"value":""},"TRAINING_STORAGE":{"value":""}}` | Define environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| modelService.running.consumer.image | object | `{"name":"mrs-job-consumer","pullPolicy":"IfNotPresent","repository":"europe-west3-docker.pkg.dev/rasa-releases/mrs-job-consumer/","tag":"1.1.1"}` | Define image settings |
| modelService.running.consumer.image.name | string | `"mrs-job-consumer"` | Specifies image name |
| modelService.running.consumer.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| modelService.running.consumer.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/mrs-job-consumer/"` | Specifies image repository |
| modelService.running.consumer.image.tag | string | `"1.1.1"` | Specifies image tag |
| modelService.running.consumer.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| modelService.running.consumer.podAnnotations | object | `{}` | Annotations to add to the pod |
| modelService.running.consumer.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| modelService.running.consumer.rasaReadinessProbe.failureThreshold | int | `50` | Allowed number of failed readiness checks until Rasa container inside the pod is considered unreachable and unable to serve requests. # Total possible readiness check = initial delay + check interval x failure threshold |
| modelService.running.consumer.rasaReadinessProbe.initialDelaySeconds | int | `10` | Initial delay after which readiness probe will be run on the container which is running Rasa deployment. # Readiness check assess if Rasa is ready to serve requests. |
| modelService.running.consumer.rasaReadinessProbe.intervalInSeconds | int | `5` | Interval (in seconds) on which readiness check will be performed. |
| modelService.running.consumer.rasaStartupProbe.failureThreshold | int | `50` | Allowed number of failed startup checks until Rasa app inside the container is considered not started. # Total possible startup check = initial delay + check interval x failure threshold |
| modelService.running.consumer.rasaStartupProbe.initialDelaySeconds | int | `10` | Initial delay after which startup probe will be run on the container which is running Rasa deployment. # Readiness check assess if Rasa application is ready. |
| modelService.running.consumer.rasaStartupProbe.intervalInSeconds | int | `5` | Interval (in seconds) on which startup check will be performed. |
| modelService.running.consumer.replicaCount | int | `1` | Specifies number of replicas |
| modelService.running.consumer.resources | object | `{}` | Specifies the resources limits and requests |
| modelService.running.consumer.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| modelService.running.consumer.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| modelService.running.consumer.volumeMounts | list | `[]` | Specifies additional volumes to mount |
| modelService.running.consumer.volumes | list | `[]` | Specify additional volumes # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| modelService.running.enabled | bool | `true` |  |
| modelService.running.orchestrator.additionalContainers | list | `[]` | Allows to specify additional containers for the deployment |
| modelService.running.orchestrator.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| modelService.running.orchestrator.envFrom | list | `[]` | envFrom is used to add environment variables from ConfigMap or Secret |
| modelService.running.orchestrator.environmentVariables | object | `{"CLOUDSDK_COMPUTE_ZONE":{"value":""},"DEPLOYMENT_JOB_TOPIC":{"value":""},"DEPLOYMENT_RESULT_CONSUMER_GROUP_ID":{"value":""},"DEPLOYMENT_RESULT_TOPIC":{"value":""},"DEPLOYMENT_STORAGE_BUCKET":{"value":""},"DEPLOYMENT_STORAGE_SIGNED_URL_SERVICE_ACCOUNT":{"secret":{"key":"TRAINING_STORAGE_SIGNED_URL_SERVICE_ACCOUNT","name":"studio-secrets"}},"GOOGLE_CLOUD_PROJECT":{"value":""},"LOGGING_LEVEL":{"value":"INFO"},"STORAGE_TYPE":{"value":""},"TRAINING_STORAGE_SIGNED_URL_SERVICE_ACCOUNT":{"secret":{"key":"TRAINING_STORAGE_SIGNED_URL_SERVICE_ACCOUNT","name":"studio-secrets"}}}` | Define environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| modelService.running.orchestrator.image | object | `{"name":"mrs-orchestrator","pullPolicy":"IfNotPresent","repository":"europe-west3-docker.pkg.dev/rasa-releases/mrs-orchestrator/","tag":"1.1.1"}` | Define image settings |
| modelService.running.orchestrator.image.name | string | `"mrs-orchestrator"` | Specifies image name |
| modelService.running.orchestrator.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| modelService.running.orchestrator.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/mrs-orchestrator/"` | Specifies image repository |
| modelService.running.orchestrator.image.tag | string | `"1.1.1"` | Specifies image tag |
| modelService.running.orchestrator.ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}],"labels":{},"tls":[]}` | Configure the ingress resource. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| modelService.running.orchestrator.ingress.annotations | object | `{}` | Annotations to add to the ingress |
| modelService.running.orchestrator.ingress.className | string | `""` | Specifies the ingress className to be used |
| modelService.running.orchestrator.ingress.enabled | bool | `false` | Specifies whether an ingress service should be created |
| modelService.running.orchestrator.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | Specifies the hosts for this ingress |
| modelService.running.orchestrator.ingress.labels | object | `{}` | Labels to add to the ingress |
| modelService.running.orchestrator.ingress.tls | list | `[]` | Spefices the TLS configuration for ingress |
| modelService.running.orchestrator.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8001,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| modelService.running.orchestrator.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| modelService.running.orchestrator.podAnnotations | object | `{}` | Annotations to add to the pod |
| modelService.running.orchestrator.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| modelService.running.orchestrator.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8001,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| modelService.running.orchestrator.replicaCount | int | `1` | Specifies number of replicas |
| modelService.running.orchestrator.resources | object | `{}` | Specifies the resources limits and requests |
| modelService.running.orchestrator.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| modelService.running.orchestrator.service | object | `{"port":8001,"targetPort":8001,"type":"ClusterIP"}` | Define service |
| modelService.running.orchestrator.service.port | int | `8001` | Specify service port |
| modelService.running.orchestrator.service.targetPort | int | `8001` | Specify service target port |
| modelService.running.orchestrator.service.type | string | `"ClusterIP"` | Specify service type # Use `NodePort` if using GCP ingress controller, in ALL other cases keep `ClusterIP`. |
| modelService.running.orchestrator.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| modelService.running.orchestrator.volumeMounts | list | `[]` | Specifies additional volumes to mount |
| modelService.running.orchestrator.volumes | list | `[]` | specify additional volumes # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| modelService.running.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Define service account |
| modelService.running.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| modelService.running.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| modelService.running.serviceAccount.name | string | `""` | The name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| modelService.runsInCluster | bool | `true` | Describes if service is run inside cluster or not. # It is used during the initialization procedure or API clients which communicate with K8S API. |
| modelService.training.consumer.additionalContainers | list | `[]` | additionalContainers allows to specify additional containers for the deployment |
| modelService.training.consumer.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| modelService.training.consumer.envFrom | list | `[]` | envFrom is used to add environment variables from ConfigMap or Secret |
| modelService.training.consumer.environmentVariables | object | `{"CLOUDSDK_COMPUTE_ZONE":{"value":""},"GCS_BUCKET_NAME":{"value":""},"GOOGLE_CLOUD_PROJECT":{"value":""},"KAFKA_JOB_TOPIC":{"value":""},"KAFKA_RESULT_TOPIC":{"value":""},"KUBERNETES_BASE_TRAINING_DATA_PATH":{"value":"/home"},"KUBERNETES_JOB_BOT_CONFIG_MOUNT":{"value":"/app"},"MODEL_TRAINING_KAFKA_CONSUMER_ID":{"value":""},"TRAINING_STORAGE":{"value":""}}` | Define environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| modelService.training.consumer.image | object | `{"name":"mts-job-consumer","pullPolicy":"IfNotPresent","repository":"europe-west3-docker.pkg.dev/rasa-releases/mts-job-consumer/","tag":"1.1.1"}` | Define image settings |
| modelService.training.consumer.image.name | string | `"mts-job-consumer"` | Specifies image name |
| modelService.training.consumer.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| modelService.training.consumer.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/mts-job-consumer/"` | Specifies image repository |
| modelService.training.consumer.image.tag | string | `"1.1.1"` | Specifies image tag |
| modelService.training.consumer.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| modelService.training.consumer.podAnnotations | object | `{}` | Annotations to add to the pod |
| modelService.training.consumer.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| modelService.training.consumer.replicaCount | int | `1` | Specifies number of replicas |
| modelService.training.consumer.resources | object | `{}` | Specifies the resources limits and requests |
| modelService.training.consumer.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| modelService.training.consumer.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| modelService.training.consumer.volumeMounts | list | `[]` | volumeMounts specifies additional volumes to mount |
| modelService.training.consumer.volumes | list | `[]` | volumes specify additional volumes # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| modelService.training.enabled | bool | `true` |  |
| modelService.training.orchestrator.additionalContainers | list | `[]` | Allows to specify additional containers for the deployment |
| modelService.training.orchestrator.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| modelService.training.orchestrator.envFrom | list | `[]` | envFrom is used to add environment variables from ConfigMap or Secret |
| modelService.training.orchestrator.environmentVariables | object | `{"CLOUDSDK_COMPUTE_ZONE":{"value":""},"GOOGLE_CLOUD_PROJECT":{"value":""},"THIRD_PARTY_STORAGE_BUCKET":{"value":""},"TRAINING_JOB_TOPIC":{"value":""},"TRAINING_RESULT_CONSUMER_GROUP_ID":{"value":""},"TRAINING_RESULT_TOPIC":{"value":""},"TRAINING_STORAGE":{"value":""},"TRAINING_STORAGE_BUCKET":{"value":""},"TRAINING_STORAGE_SIGNED_URL_SERVICE_ACCOUNT":{"secret":{"key":"TRAINING_STORAGE_SIGNED_URL_SERVICE_ACCOUNT","name":"studio-secrets"}}}` | Define environment variables for deployment Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| modelService.training.orchestrator.image | object | `{"name":"mts-orchestrator","pullPolicy":"IfNotPresent","repository":"europe-west3-docker.pkg.dev/rasa-releases/mts-orchestrator/","tag":"1.1.1"}` | Define image settings |
| modelService.training.orchestrator.image.name | string | `"mts-orchestrator"` | Specifies image name |
| modelService.training.orchestrator.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| modelService.training.orchestrator.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/mts-orchestrator/"` | Specifies image repository |
| modelService.training.orchestrator.image.tag | string | `"1.1.1"` | Specifies image tag |
| modelService.training.orchestrator.ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}],"labels":{},"tls":[]}` | Configure the ingress resource. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| modelService.training.orchestrator.ingress.annotations | object | `{}` | Annotations to add to the ingress |
| modelService.training.orchestrator.ingress.className | string | `""` | Specifies the ingress className to be used |
| modelService.training.orchestrator.ingress.enabled | bool | `false` | Specifies whether an ingress service should be created |
| modelService.training.orchestrator.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | Specifies the hosts for this ingress |
| modelService.training.orchestrator.ingress.labels | object | `{}` | Labels to add to the ingress |
| modelService.training.orchestrator.ingress.tls | list | `[]` | Spefices the TLS configuration for ingress |
| modelService.training.orchestrator.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| modelService.training.orchestrator.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| modelService.training.orchestrator.podAnnotations | object | `{}` | Annotations to add to the pod |
| modelService.training.orchestrator.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| modelService.training.orchestrator.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| modelService.training.orchestrator.replicaCount | int | `1` | Specifies number of replicas |
| modelService.training.orchestrator.resources | object | `{}` | Specifies the resources limits and requests |
| modelService.training.orchestrator.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| modelService.training.orchestrator.service | object | `{"port":8000,"targetPort":8000,"type":"ClusterIP"}` | Define service |
| modelService.training.orchestrator.service.port | int | `8000` | Specify service port |
| modelService.training.orchestrator.service.targetPort | int | `8000` | Specify service target port |
| modelService.training.orchestrator.service.type | string | `"ClusterIP"` | Specify service type # Use `NodePort` if using GCP ingress controller, in ALL other cases keep `ClusterIP`. |
| modelService.training.orchestrator.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| modelService.training.orchestrator.volumeMounts | string | `nil` | Specifies additional volumes to mount |
| modelService.training.orchestrator.volumes | string | `nil` | Specify additional volumes # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| modelService.training.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Define service account |
| modelService.training.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| modelService.training.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| modelService.training.serviceAccount.name | string | `""` | The name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| nameOverride | string | `""` | Override name of app |
| networkPolicy.denyAll | bool | `false` | Specifies whether to apply denyAll network policy |
| networkPolicy.enabled | bool | `false` | Specifies whether to enable network policies |
| networkPolicy.nodeCIDR | list | `[]` | Allow for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes |
| podLabels | object | `{}` | podLabels defines labels to add to all Studio pod(s) |
| repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/studio/"` | Specifies image repository for Studio |
| studioEnabled | bool | `true` |  |
| tag | string | `"0.1.3"` | Specifies image tag for Studio # Overrides the image tag whose default is the chart appVersion. |
| webClient.additionalContainers | list | `[]` | webClient.additionalContainers allows to specify additional containers for the deployment |
| webClient.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| webClient.envFrom | list | `[]` | webClient.envFrom is used to add environment variables from ConfigMap or Secret |
| webClient.environmentVariables | object | `{"API_ENDPOINT":"","KEYCLOAK_CLIENT_ID":"studio-local","KEYCLOAK_REALM":"rasa-local-dev","KEYCLOAK_URL":""}` | Define environment variables for deployment |
| webClient.image | object | `{"name":"studio-web-client","pullPolicy":"IfNotPresent"}` | Define image settings |
| webClient.image.name | string | `"studio-web-client"` | Specifies image repository |
| webClient.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| webClient.ingress | object | `{"annotations":{},"className":"","enabled":true,"hosts":[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}],"labels":{},"tls":[]}` | Configure the ingress resource that allows you to access the deployment installation. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| webClient.ingress.annotations | object | `{}` | Annotations to add to the ingress |
| webClient.ingress.className | string | `""` | Specifies the ingress className to be used |
| webClient.ingress.enabled | bool | `true` | Specifies whether an ingress service should be created |
| webClient.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | Specifies the hosts for this ingress |
| webClient.ingress.labels | object | `{}` | Labels to add to the ingress |
| webClient.ingress.tls | list | `[]` | Spefices the TLS configuration for ingress |
| webClient.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":"http","scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| webClient.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| webClient.podAnnotations | object | `{}` | Annotations to add to the pod |
| webClient.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| webClient.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":"http","scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| webClient.replicaCount | int | `1` | Specifies number of replicas |
| webClient.resources | object | `{}` | Specifies the resources limits and requests |
| webClient.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| webClient.service | object | `{"port":80,"targetPort":80,"type":"ClusterIP"}` | Define service |
| webClient.service.port | int | `80` | Specify service port |
| webClient.service.type | string | `"ClusterIP"` | Specify service type |
| webClient.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Define service account |
| webClient.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| webClient.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| webClient.serviceAccount.name | string | `""` | The name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| webClient.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
