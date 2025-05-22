# studio

This chart bootstraps Studio deployment on a Kubernetes cluster using the Helm package manager.

![Version: 2.1.0-rc.0](https://img.shields.io/badge/Version-2.1.0--rc.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 2.1.0-rc.0
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
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 2.1.0-rc.0
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
| backend.additionalContainers | list | `[]` | backend.additionalContainers defines additional containers to run alongside the main Studio Backend container. These containers will be part of the same pod and share the pod's network namespace. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] Ref: https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers |
| backend.affinity | object | `{}` | backend.affinity defines affinity rules for the backend pods. This controls where the pods can be scheduled. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| backend.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | backend.autoscaling defines the Horizontal Pod Autoscaling configuration. This enables automatic scaling of the backend deployment based on metrics. Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/ |
| backend.autoscaling.enabled | bool | `false` | backend.autoscaling.enabled determines whether to enable horizontal pod autoscaling. |
| backend.autoscaling.maxReplicas | int | `100` | backend.autoscaling.maxReplicas is the maximum number of replicas. |
| backend.autoscaling.minReplicas | int | `1` | backend.autoscaling.minReplicas is the minimum number of replicas. |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `80` | backend.autoscaling.targetCPUUtilizationPercentage is the target CPU utilization percentage. The HPA will scale the deployment to maintain this CPU utilization. Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details |
| backend.envFrom | list | `[]` | backend.envFrom defines additional environment variables from ConfigMap or Secret. These will be mounted as environment variables in the container. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables |
| backend.environmentVariables | object | `{"DATABASE_URL":{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}},"DELETE_CONVERSATIONS_CRON_EXPRESSION":{"value":"0 * * * *"},"DELETE_CONVERSATIONS_OLDER_THAN_HOURS":{"value":""},"KEYCLOAK_API_CLIENT_ID":{"value":"admin-cli"},"KEYCLOAK_API_PASSWORD":{"secret":{"key":"KEYCLOAK_API_PASSWORD","name":"studio-secrets"}},"KEYCLOAK_API_USERNAME":{"value":"realmadmin"},"KEYCLOAK_REALM":{"value":"rasa-studio"}}` | backend.environmentVariables defines the environment variables for the Studio Backend deployment. These variables configure the runtime behavior of the backend service. Each variable can be set either directly with a value or from a Kubernetes secret. Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. Ref: https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/ |
| backend.environmentVariables.DATABASE_URL | object | `{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}}` | backend.environmentVariables.DATABASE_URL is the database connection URL for Studio Backend. Format: postgresql://${database.username}:${database.password}@${database.host}:${database.port}/studio?schema=public This should be stored in a Kubernetes secret for security. Ref: https://kubernetes.io/docs/concepts/configuration/secret/ |
| backend.environmentVariables.DELETE_CONVERSATIONS_CRON_EXPRESSION | object | `{"value":"0 * * * *"}` | backend.environmentVariables.DELETE_CONVERSATIONS_CRON_EXPRESSION is the cron schedule for conversation cleanup job. Format: "minute hour day-of-month month day-of-week" Example: "0 * * * *" runs every hour Default: Runs every hour at minute 0 Ref: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax |
| backend.environmentVariables.DELETE_CONVERSATIONS_OLDER_THAN_HOURS | object | `{"value":""}` | backend.environmentVariables.DELETE_CONVERSATIONS_OLDER_THAN_HOURS is the conversation data retention period in hours. Conversations older than this value will be deleted by the cleanup cron job. Leave empty to disable automatic conversation cleanup. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/ |
| backend.environmentVariables.KEYCLOAK_API_CLIENT_ID | object | `{"value":"admin-cli"}` | backend.environmentVariables.KEYCLOAK_API_CLIENT_ID is the Keycloak client ID for API access. This client is used by Studio Backend to authenticate with Keycloak. |
| backend.environmentVariables.KEYCLOAK_API_PASSWORD | object | `{"secret":{"key":"KEYCLOAK_API_PASSWORD","name":"studio-secrets"}}` | backend.environmentVariables.KEYCLOAK_API_PASSWORD is the password for Studio Backend to communicate with Keycloak. This should be stored in a Kubernetes secret for security. Ref: https://kubernetes.io/docs/concepts/configuration/secret/ |
| backend.environmentVariables.KEYCLOAK_API_USERNAME | object | `{"value":"realmadmin"}` | backend.environmentVariables.KEYCLOAK_API_USERNAME is the username for Studio Backend to communicate with Keycloak. This account needs appropriate permissions in Keycloak to manage users. |
| backend.environmentVariables.KEYCLOAK_REALM | object | `{"value":"rasa-studio"}` | backend.environmentVariables.KEYCLOAK_REALM is the Keycloak realm name for Studio. This defines the authentication realm where Studio users will be managed. |
| backend.image | object | `{"name":"studio-backend","pullPolicy":"IfNotPresent"}` | backend.image defines the container image settings for the backend service. This section defines the container image settings for the backend service. Ref: https://kubernetes.io/docs/concepts/containers/images/ |
| backend.image.name | string | `"studio-backend"` | backend.image.name is the name of the Studio Backend container image. This should match the image name in your container registry. |
| backend.image.pullPolicy | string | `"IfNotPresent"` | backend.image.pullPolicy is the container image pull policy. Valid values: Always, IfNotPresent, Never Always: Always pull the image IfNotPresent: Only pull if not present locally Never: Never pull the image Ref: https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy |
| backend.ingress | object | `{"additionalAnnotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` | backend.ingress defines how the backend service is exposed externally. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/ |
| backend.ingress.additionalAnnotations | object | `{}` | backend.ingress.additionalAnnotations defines additional annotations for the ingress resource. Example:   kubernetes.io/ingress.class: nginx   cert-manager.io/cluster-issuer: letsencrypt-prod Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| backend.ingress.className | string | `""` | backend.ingress.className is the ingress class name. This should match your cluster's ingress controller. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class |
| backend.ingress.enabled | bool | `true` | backend.ingress.enabled determines whether to create an ingress resource. |
| backend.ingress.labels | object | `{}` | backend.ingress.labels defines labels to add to the ingress resource. Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| backend.ingress.tls | list | `[]` | backend.ingress.tls defines the TLS configuration for the ingress. Example: - secretName: chart-example-tls   hosts:     - chart-example.local |
| backend.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | backend.livenessProbe defines the liveness probe configuration. This determines if the container is alive and functioning. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| backend.livenessProbe.enabled | bool | `true` | backend.livenessProbe.enabled determines whether to enable the liveness probe. |
| backend.livenessProbe.failureThreshold | int | `6` | backend.livenessProbe.failureThreshold is the number of failures before the container is considered unhealthy. |
| backend.livenessProbe.httpGet | object | `{"path":"/api/health","port":4000,"scheme":"HTTP"}` | backend.livenessProbe.httpGet defines the HTTP GET probe configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command |
| backend.livenessProbe.httpGet.path | string | `"/api/health"` | backend.livenessProbe.httpGet.path is the path to check for liveness. |
| backend.livenessProbe.httpGet.port | int | `4000` | backend.livenessProbe.httpGet.port is the port to check for liveness. |
| backend.livenessProbe.httpGet.scheme | string | `"HTTP"` | backend.livenessProbe.httpGet.scheme is the protocol to use for the check. |
| backend.livenessProbe.initialDelaySeconds | int | `15` | backend.livenessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. |
| backend.livenessProbe.periodSeconds | int | `15` | backend.livenessProbe.periodSeconds is how often to perform the probe. |
| backend.livenessProbe.successThreshold | int | `1` | backend.livenessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. |
| backend.livenessProbe.timeoutSeconds | int | `5` | backend.livenessProbe.timeoutSeconds is the number of seconds after which the probe times out. |
| backend.migration | object | `{"affinity":{},"enabled":true,"image":{"name":"studio-database-migration","pullPolicy":"IfNotPresent"},"nodeSelector":{},"tolerations":[],"waitForIt":false,"waitFotItContainer":{"image":"postgres:17.2"}}` | backend.migration defines the database migration job configuration. This section controls the database schema migration process. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/job/ |
| backend.migration.affinity | object | `{}` | backend.migration.affinity defines affinity rules for the migration job. This controls where the job can be scheduled. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| backend.migration.enabled | bool | `true` | backend.migration.enabled determines whether to enable the database migration job. Set to false if you want to handle migrations manually. |
| backend.migration.image | object | `{"name":"studio-database-migration","pullPolicy":"IfNotPresent"}` | backend.migration.image defines the image configuration for the migration job. |
| backend.migration.image.name | string | `"studio-database-migration"` | backend.migration.image.name is the name of the migration container image. |
| backend.migration.image.pullPolicy | string | `"IfNotPresent"` | backend.migration.image.pullPolicy is the container image pull policy. |
| backend.migration.nodeSelector | object | `{}` | backend.migration.nodeSelector defines which nodes the migration job can run on. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| backend.migration.tolerations | list | `[]` | backend.migration.tolerations defines tolerations for the migration job. This allows the job to run on nodes with matching taints. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| backend.migration.waitForIt | bool | `false` | backend.migration.waitForIt determines whether to wait for the database to be ready before running migrations. |
| backend.migration.waitFotItContainer | object | `{"image":"postgres:17.2"}` | backend.migration.waitFotItContainer defines the configuration for the wait-for-it container. |
| backend.nodeSelector | object | `{}` | backend.nodeSelector defines which nodes the backend pods can run on. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| backend.podAnnotations | object | `{}` | backend.podAnnotations defines annotations to add to the backend pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-backend: runtime/default Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| backend.podSecurityContext | object | `{"enabled":true}` | backend.podSecurityContext defines the security settings for the entire pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| backend.podSecurityContext.enabled | bool | `true` | backend.podSecurityContext.enabled determines whether to enable the pod security context. |
| backend.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | backend.readinessProbe defines the readiness probe configuration. This determines if the container is ready to receive traffic. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| backend.readinessProbe.enabled | bool | `true` | backend.readinessProbe.enabled determines whether to enable the readiness probe. |
| backend.readinessProbe.failureThreshold | int | `6` | backend.readinessProbe.failureThreshold is the number of failures before the container is considered not ready. |
| backend.readinessProbe.httpGet | object | `{"path":"/api/health","port":4000,"scheme":"HTTP"}` | backend.readinessProbe.httpGet defines the HTTP GET probe configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-readiness-probe |
| backend.readinessProbe.httpGet.path | string | `"/api/health"` | backend.readinessProbe.httpGet.path is the path to check for readiness. |
| backend.readinessProbe.httpGet.port | int | `4000` | backend.readinessProbe.httpGet.port is the port to check for readiness. |
| backend.readinessProbe.httpGet.scheme | string | `"HTTP"` | backend.readinessProbe.httpGet.scheme is the protocol to use for the check. |
| backend.readinessProbe.initialDelaySeconds | int | `15` | backend.readinessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. |
| backend.readinessProbe.periodSeconds | int | `15` | backend.readinessProbe.periodSeconds is how often to perform the probe. |
| backend.readinessProbe.successThreshold | int | `1` | backend.readinessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. |
| backend.readinessProbe.timeoutSeconds | int | `5` | backend.readinessProbe.timeoutSeconds is the number of seconds after which the probe times out. |
| backend.replicaCount | int | `1` | backend.replicaCount is the number of replicas for the Studio Backend deployment. Increase this value for high availability and better load distribution. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#replicas |
| backend.resources | object | `{}` | backend.resources defines the resource limits and requests for Studio Backend. This controls the compute resources allocated to the backend container. Ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| backend.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | backend.securityContext defines the security settings for the backend container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| backend.securityContext.allowPrivilegeEscalation | bool | `false` | backend.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. Should be false for security best practices. |
| backend.securityContext.capabilities | object | `{"drop":["ALL"]}` | backend.securityContext.capabilities defines the Linux capabilities configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container |
| backend.securityContext.capabilities.drop | list | `["ALL"]` | backend.securityContext.capabilities.drop defines capabilities to drop from the container. ALL drops all capabilities for maximum security. |
| backend.securityContext.enabled | bool | `true` | backend.securityContext.enabled determines whether to enable the security context. |
| backend.securityContext.runAsNonRoot | bool | `true` | backend.securityContext.runAsNonRoot determines whether to run the container as a non-root user. Should be true for security best practices. |
| backend.service | object | `{"port":80,"targetPort":4000,"type":"ClusterIP"}` | backend.service defines how the backend service is exposed within the cluster. Ref: https://kubernetes.io/docs/concepts/services-networking/service/ |
| backend.service.port | int | `80` | backend.service.port is the port number for the service. |
| backend.service.targetPort | int | `4000` | backend.service.targetPort is the target port in the container. This should match the port your application listens on. |
| backend.service.type | string | `"ClusterIP"` | backend.service.type is the type of Kubernetes service. Valid values: ClusterIP, NodePort, LoadBalancer, ExternalName Ref: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types |
| backend.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | backend.serviceAccount defines the Kubernetes service account used by the backend pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| backend.serviceAccount.annotations | object | `{}` | backend.serviceAccount.annotations defines annotations to add to the service account. Useful for cloud provider specific configurations. |
| backend.serviceAccount.create | bool | `false` | backend.serviceAccount.create determines whether to create a new service account. |
| backend.serviceAccount.name | string | `""` | backend.serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| backend.tolerations | list | `[]` | backend.tolerations defines tolerations for the backend pods. This allows the pods to run on nodes with matching taints. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| config.affinity | object | `{}` | Pod affinity and anti-affinity rules for all deployments. These settings can be overridden by component-specific configurations. |
| config.connectionType | string | `"http"` | Define if you will be using https or http with the ingressHost. Valid values are "http" or "https". This setting affects how services communicate with each other. |
| config.database | object | `{"host":"","keycloakDatabaseName":"keycloak","password":{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"},"port":"5432","preferSSL":"true","rejectUnauthorized":"","username":""}` | The postgres database instance details for Studio to connect to. This section configures the database connection parameters for Studio. |
| config.database.host | string | `""` | The database host name or IP address where PostgreSQL is running. Example: "postgres.example.com" or "10.0.0.1" |
| config.database.keycloakDatabaseName | string | `"keycloak"` | The database name for Keycloak user management service. This is used by Keycloak to store its user management data. |
| config.database.password | object | `{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"}` | The database password configuration. This references a Kubernetes secret containing the database password. |
| config.database.port | string | `"5432"` | The database port number for PostgreSQL. Default PostgreSQL port is 5432 |
| config.database.preferSSL | string | `"true"` | Set to true if you want to use SSL for database connection. When enabled, Studio will attempt to establish an encrypted connection to the database. |
| config.database.rejectUnauthorized | string | `""` | If true, the server will reject database connections which are not present in the list of supplied CAs. This provides additional security by ensuring only trusted certificates are accepted. |
| config.database.username | string | `""` | The database username for Studio to connect with. This user should have appropriate permissions on the database. |
| config.ingressAnnotations | object | `{}` | Define the ingress annotations to be used for ALL the ingress resources. These annotations will be applied to all ingress resources created by this chart. Example:   kubernetes.io/ingress.class: nginx   cert-manager.io/cluster-issuer: letsencrypt-prod |
| config.ingressHost | string | `"INGRESS.HOST.NAME"` | Defines the host name for all Studio ingress resources. This value is used as an anchor (&dns_hostname) for referencing the host name across multiple places in the Helm chart. WARNING: Do NOT delete or modify the anchor (&dns_hostname) as it is critical for the proper functioning of the chart. If you need to update the host name, only change the value (INGRESS.HOST.NAME), keeping the anchor intact. |
| config.keycloak | object | `{"adminPassword":{"secretKey":"KEYCLOAK_ADMIN_PASSWORD","secretName":"studio-secrets"},"adminUsername":"kcadmin","url":""}` | config.keycloak defines the Keycloak configuration settings. This section configures the authentication and authorization service. |
| config.keycloak.adminPassword | object | `{"secretKey":"KEYCLOAK_ADMIN_PASSWORD","secretName":"studio-secrets"}` | config.keycloak.adminPassword defines the admin password for Keycloak. This password is used to login to the Keycloak admin console. The password is stored in a Kubernetes secret. |
| config.keycloak.adminUsername | string | `"kcadmin"` | config.keycloak.adminUsername is the admin username for Keycloak. This username is used to login to the Keycloak admin console. |
| config.keycloak.url | string | `""` | config.keycloak.url overrides the default service endpoint for Keycloak. Format is `http(s)://<ingressHost>/auth`. Required only if your cluster redirects internal HTTP traffic to HTTPS. |
| config.nodeSelector | object | `{}` | Common pod scheduling configuration for all deployments. These settings can be overridden by component-specific configurations. Not possible to combine with component-specific configurations for each scheduling option. |
| config.tolerations | list | `[]` | Pod tolerations for all deployments. These settings can be overridden by component-specific configurations. |
| deploymentAnnotations | object | `{}` | deploymentAnnotations defines annotations to add to all Studio deployments |
| deploymentLabels | object | `{}` | deploymentLabels defines labels to add to all Studio deployment |
| dnsConfig | object | `{}` | dnsConfig specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | dnsPolicy specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| eventIngestion.additionalContainers | list | `[]` | eventIngestion.additionalContainers defines additional containers to run alongside the main Event Ingestion container. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] |
| eventIngestion.affinity | object | `{}` | eventIngestion.affinity defines affinity rules for the event ingestion pods. |
| eventIngestion.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | eventIngestion.autoscaling defines the Horizontal Pod Autoscaling configuration. |
| eventIngestion.autoscaling.enabled | bool | `false` | eventIngestion.autoscaling.enabled determines whether to enable horizontal pod autoscaling. |
| eventIngestion.autoscaling.maxReplicas | int | `100` | eventIngestion.autoscaling.maxReplicas is the maximum number of replicas. |
| eventIngestion.autoscaling.minReplicas | int | `1` | eventIngestion.autoscaling.minReplicas is the minimum number of replicas. |
| eventIngestion.autoscaling.targetCPUUtilizationPercentage | int | `80` | eventIngestion.autoscaling.targetCPUUtilizationPercentage is the target CPU utilization percentage. |
| eventIngestion.enabled | bool | `true` | eventIngestion.enabled determines whether to deploy the event ingestion component. |
| eventIngestion.envFrom | list | `[]` | eventIngestion.envFrom defines additional environment variables from ConfigMap or Secret. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret |
| eventIngestion.environmentVariables | object | `{"DATABASE_URL":{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}},"KAFKA_BROKER_ADDRESS":{"value":""},"KAFKA_CA_FILE":{"value":""},"KAFKA_CERT_FILE":{"value":""},"KAFKA_CUSTOM_SSL":{"value":""},"KAFKA_DLQ_TOPIC":{"value":"rasa-events-dlq"},"KAFKA_ENABLE_SSL":{"value":""},"KAFKA_GROUP_ID":{"value":"studio"},"KAFKA_KEY_FILE":{"value":""},"KAFKA_REJECT_UNAUTHORIZED":{"value":""},"KAFKA_SASL_MECHANISM":{"value":""},"KAFKA_SASL_PASSWORD":{"secret":{"key":"KAFKA_SASL_PASSWORD","name":"studio-secrets"}},"KAFKA_SASL_USERNAME":{"value":""},"KAFKA_TOPIC":{"value":"rasa-events"},"NODE_TLS_REJECT_UNAUTHORIZED":{"value":""}}` | eventIngestion.environmentVariables defines the environment variables for the Event Ingestion deployment. Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| eventIngestion.environmentVariables.DATABASE_URL | object | `{"secret":{"key":"DATABASE_URL","name":"studio-secrets"}}` | eventIngestion.environmentVariables.DATABASE_URL is the database connection URL for Event Ingestion. Format: postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}?schema=public |
| eventIngestion.environmentVariables.KAFKA_BROKER_ADDRESS | object | `{"value":""}` | eventIngestion.environmentVariables.KAFKA_BROKER_ADDRESS is the address of the Kafka broker. |
| eventIngestion.environmentVariables.KAFKA_CA_FILE | object | `{"value":""}` | eventIngestion.environmentVariables.KAFKA_CA_FILE is the path to the CA certificate file for Kafka SSL. |
| eventIngestion.environmentVariables.KAFKA_CERT_FILE | object | `{"value":""}` | eventIngestion.environmentVariables.KAFKA_CERT_FILE is the path to the client certificate file for Kafka SSL. |
| eventIngestion.environmentVariables.KAFKA_CUSTOM_SSL | object | `{"value":""}` | eventIngestion.environmentVariables.KAFKA_CUSTOM_SSL determines whether to use custom SSL certificates for Kafka. |
| eventIngestion.environmentVariables.KAFKA_DLQ_TOPIC | object | `{"value":"rasa-events-dlq"}` | eventIngestion.environmentVariables.KAFKA_DLQ_TOPIC is the Kafka topic for unprocessed events. |
| eventIngestion.environmentVariables.KAFKA_ENABLE_SSL | object | `{"value":""}` | eventIngestion.environmentVariables.KAFKA_ENABLE_SSL determines whether to enable SSL for Kafka connections. |
| eventIngestion.environmentVariables.KAFKA_GROUP_ID | object | `{"value":"studio"}` | eventIngestion.environmentVariables.KAFKA_GROUP_ID is the Kafka consumer group ID for Studio. |
| eventIngestion.environmentVariables.KAFKA_KEY_FILE | object | `{"value":""}` | eventIngestion.environmentVariables.KAFKA_KEY_FILE is the path to the client key file for Kafka SSL. |
| eventIngestion.environmentVariables.KAFKA_REJECT_UNAUTHORIZED | object | `{"value":""}` | eventIngestion.environmentVariables.KAFKA_REJECT_UNAUTHORIZED determines whether to verify server certificates. |
| eventIngestion.environmentVariables.KAFKA_SASL_MECHANISM | object | `{"value":""}` | eventIngestion.environmentVariables.KAFKA_SASL_MECHANISM is the SASL mechanism for Kafka authentication. Supported values: plain, SCRAM-SHA-256, SCRAM-SHA-512 |
| eventIngestion.environmentVariables.KAFKA_SASL_PASSWORD | object | `{"secret":{"key":"KAFKA_SASL_PASSWORD","name":"studio-secrets"}}` | eventIngestion.environmentVariables.KAFKA_SASL_PASSWORD is the SASL password for Kafka authentication. |
| eventIngestion.environmentVariables.KAFKA_SASL_USERNAME | object | `{"value":""}` | eventIngestion.environmentVariables.KAFKA_SASL_USERNAME is the SASL username for Kafka authentication. |
| eventIngestion.environmentVariables.KAFKA_TOPIC | object | `{"value":"rasa-events"}` | eventIngestion.environmentVariables.KAFKA_TOPIC is the Kafka topic for Rasa Pro assistant events. |
| eventIngestion.environmentVariables.NODE_TLS_REJECT_UNAUTHORIZED | object | `{"value":""}` | eventIngestion.environmentVariables.NODE_TLS_REJECT_UNAUTHORIZED determines whether to allow untrusted certificates. |
| eventIngestion.image | object | `{"name":"studio-event-ingestion","pullPolicy":"IfNotPresent"}` | eventIngestion.image defines the container image settings for the event ingestion service. |
| eventIngestion.image.name | string | `"studio-event-ingestion"` | eventIngestion.image.name is the name of the Event Ingestion container image. |
| eventIngestion.image.pullPolicy | string | `"IfNotPresent"` | eventIngestion.image.pullPolicy is the container image pull policy. |
| eventIngestion.nodeSelector | object | `{}` | eventIngestion.nodeSelector defines which nodes the event ingestion pods can run on. |
| eventIngestion.podAnnotations | object | `{}` | eventIngestion.podAnnotations defines annotations to add to the event ingestion pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-event-ingestion: runtime/default |
| eventIngestion.podSecurityContext | object | `{"enabled":true}` | eventIngestion.podSecurityContext defines the security settings for the entire pod. |
| eventIngestion.podSecurityContext.enabled | bool | `true` | eventIngestion.podSecurityContext.enabled determines whether to enable the pod security context. |
| eventIngestion.replicaCount | int | `1` | eventIngestion.replicaCount is the number of replicas for the Event Ingestion deployment. |
| eventIngestion.resources | object | `{}` | eventIngestion.resources defines the resource limits and requests for the event ingestion service. |
| eventIngestion.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | eventIngestion.securityContext defines the security settings for the event ingestion container. |
| eventIngestion.securityContext.allowPrivilegeEscalation | bool | `false` | eventIngestion.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. |
| eventIngestion.securityContext.capabilities | object | `{"drop":["ALL"]}` | eventIngestion.securityContext.capabilities defines the Linux capabilities configuration. |
| eventIngestion.securityContext.capabilities.drop | list | `["ALL"]` | eventIngestion.securityContext.capabilities.drop defines capabilities to drop from the container. |
| eventIngestion.securityContext.enabled | bool | `true` | eventIngestion.securityContext.enabled determines whether to enable the security context. |
| eventIngestion.securityContext.runAsNonRoot | bool | `true` | eventIngestion.securityContext.runAsNonRoot determines whether to run the container as a non-root user. |
| eventIngestion.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | eventIngestion.serviceAccount defines the Kubernetes service account used by the event ingestion pod. |
| eventIngestion.serviceAccount.annotations | object | `{}` | eventIngestion.serviceAccount.annotations defines annotations to add to the service account. |
| eventIngestion.serviceAccount.create | bool | `false` | eventIngestion.serviceAccount.create determines whether to create a new service account. |
| eventIngestion.serviceAccount.name | string | `""` | eventIngestion.serviceAccount.name is the name of the service account to use. |
| eventIngestion.tolerations | list | `[]` | eventIngestion.tolerations defines tolerations for the event ingestion pods. |
| eventIngestion.volumeMounts | list | `[]` | eventIngestion.volumeMounts defines where to mount the volumes in the Event Ingestion container. Example: - name: config-volume   mountPath: /etc/config   readOnly: true |
| eventIngestion.volumes | list | `[]` | eventIngestion.volumes defines additional volumes for the Event Ingestion container. Example: - name: config-volume   configMap:     name: special-config |
| fullnameOverride | string | `""` | Override the full qualified app name |
| global.additionalDeploymentLabels | object | `{}` | global.additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| global.ingressHost | string | `nil` |  |
| hostNetwork | bool | `false` | Controls whether the pod may use the node network namespace |
| imagePullSecrets | list | `[]` | imagePullSecret defines repository pull secrets |
| keycloak.additionalContainers | list | `[]` | keycloak.additionalContainers defines additional containers to run alongside the main Keycloak container. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] |
| keycloak.affinity | object | `{}` | keycloak.affinity defines affinity rules for the Keycloak pods. |
| keycloak.enabled | bool | `true` | keycloak.enabled determines whether to deploy the Keycloak authentication service. |
| keycloak.envFrom | list | `[]` | keycloak.envFrom defines additional environment variables from ConfigMap or Secret. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret |
| keycloak.environmentVariables | object | `{"KC_PROXY":{"value":"edge"}}` | keycloak.environmentVariables defines the environment variables for the Keycloak deployment. Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| keycloak.environmentVariables.KC_PROXY | object | `{"value":"edge"}` | keycloak.environmentVariables.KC_PROXY determines the proxy configuration for Keycloak. Set to "edge" to enable HTTP communication between proxy/load balancer and Keycloak. Useful for secure internal networks where the reverse proxy maintains HTTPS with clients. |
| keycloak.image | object | `{"name":"studio-keycloak","pullPolicy":"IfNotPresent"}` | keycloak.image defines the container image settings for the Keycloak service. |
| keycloak.image.name | string | `"studio-keycloak"` | keycloak.image.name is the name of the Keycloak container image. |
| keycloak.image.pullPolicy | string | `"IfNotPresent"` | keycloak.image.pullPolicy is the container image pull policy. |
| keycloak.ingress | object | `{"additionalAnnotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` | keycloak.ingress defines how the Keycloak service is exposed externally. |
| keycloak.ingress.additionalAnnotations | object | `{}` | keycloak.ingress.additionalAnnotations defines additional annotations for the ingress resource. |
| keycloak.ingress.className | string | `""` | keycloak.ingress.className is the ingress class name. |
| keycloak.ingress.enabled | bool | `true` | keycloak.ingress.enabled determines whether to create an ingress resource. |
| keycloak.ingress.labels | object | `{}` | keycloak.ingress.labels defines labels to add to the ingress resource. |
| keycloak.ingress.tls | list | `[]` | keycloak.ingress.tls defines the TLS configuration for the ingress. |
| keycloak.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/auth","port":8080,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | keycloak.livenessProbe defines the liveness probe configuration. |
| keycloak.livenessProbe.enabled | bool | `true` | keycloak.livenessProbe.enabled determines whether to enable the liveness probe. |
| keycloak.livenessProbe.failureThreshold | int | `6` | keycloak.livenessProbe.failureThreshold is the number of failures before the container is considered unhealthy. |
| keycloak.livenessProbe.httpGet | object | `{"path":"/auth","port":8080,"scheme":"HTTP"}` | keycloak.livenessProbe.httpGet defines the HTTP GET probe configuration. |
| keycloak.livenessProbe.httpGet.path | string | `"/auth"` | keycloak.livenessProbe.httpGet.path is the path to check for liveness. |
| keycloak.livenessProbe.httpGet.port | int | `8080` | keycloak.livenessProbe.httpGet.port is the port to check for liveness. |
| keycloak.livenessProbe.httpGet.scheme | string | `"HTTP"` | keycloak.livenessProbe.httpGet.scheme is the protocol to use for the check. |
| keycloak.livenessProbe.initialDelaySeconds | int | `30` | keycloak.livenessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. |
| keycloak.livenessProbe.periodSeconds | int | `15` | keycloak.livenessProbe.periodSeconds is how often to perform the probe. |
| keycloak.livenessProbe.successThreshold | int | `1` | keycloak.livenessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. |
| keycloak.livenessProbe.timeoutSeconds | int | `5` | keycloak.livenessProbe.timeoutSeconds is the number of seconds after which the probe times out. |
| keycloak.nodeSelector | object | `{}` | keycloak.nodeSelector defines which nodes the Keycloak pods can run on. |
| keycloak.podAnnotations | object | `{}` | keycloak.podAnnotations defines annotations to add to the Keycloak pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-keycloak: runtime/default |
| keycloak.podSecurityContext | object | `{"enabled":true}` | keycloak.podSecurityContext defines the security settings for the entire pod. |
| keycloak.podSecurityContext.enabled | bool | `true` | keycloak.podSecurityContext.enabled determines whether to enable the pod security context. |
| keycloak.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/auth","port":8080,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | keycloak.readinessProbe defines the readiness probe configuration. |
| keycloak.readinessProbe.enabled | bool | `true` | keycloak.readinessProbe.enabled determines whether to enable the readiness probe. |
| keycloak.readinessProbe.failureThreshold | int | `6` | keycloak.readinessProbe.failureThreshold is the number of failures before the container is considered not ready. |
| keycloak.readinessProbe.httpGet | object | `{"path":"/auth","port":8080,"scheme":"HTTP"}` | keycloak.readinessProbe.httpGet defines the HTTP GET probe configuration. |
| keycloak.readinessProbe.httpGet.path | string | `"/auth"` | keycloak.readinessProbe.httpGet.path is the path to check for readiness. |
| keycloak.readinessProbe.httpGet.port | int | `8080` | keycloak.readinessProbe.httpGet.port is the port to check for readiness. |
| keycloak.readinessProbe.httpGet.scheme | string | `"HTTP"` | keycloak.readinessProbe.httpGet.scheme is the protocol to use for the check. |
| keycloak.readinessProbe.initialDelaySeconds | int | `30` | keycloak.readinessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. |
| keycloak.readinessProbe.periodSeconds | int | `15` | keycloak.readinessProbe.periodSeconds is how often to perform the probe. |
| keycloak.readinessProbe.successThreshold | int | `1` | keycloak.readinessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. |
| keycloak.readinessProbe.timeoutSeconds | int | `5` | keycloak.readinessProbe.timeoutSeconds is the number of seconds after which the probe times out. |
| keycloak.replicaCount | int | `1` | keycloak.replicaCount is the number of replicas for the Keycloak deployment. |
| keycloak.resources | object | `{}` | keycloak.resources defines the resource limits and requests for the Keycloak service. |
| keycloak.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | keycloak.securityContext defines the security settings for the Keycloak container. |
| keycloak.securityContext.allowPrivilegeEscalation | bool | `false` | keycloak.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. |
| keycloak.securityContext.capabilities | object | `{"drop":["ALL"]}` | keycloak.securityContext.capabilities defines the Linux capabilities configuration. |
| keycloak.securityContext.capabilities.drop | list | `["ALL"]` | keycloak.securityContext.capabilities.drop defines capabilities to drop from the container. |
| keycloak.securityContext.enabled | bool | `true` | keycloak.securityContext.enabled determines whether to enable the security context. |
| keycloak.securityContext.runAsNonRoot | bool | `true` | keycloak.securityContext.runAsNonRoot determines whether to run the container as a non-root user. |
| keycloak.service | object | `{"port":80,"targetPort":8080,"type":"ClusterIP"}` | keycloak.service defines how the Keycloak service is exposed within the cluster. |
| keycloak.service.port | int | `80` | keycloak.service.port is the port number for the service. |
| keycloak.service.targetPort | int | `8080` | keycloak.service.targetPort is the target port in the container. |
| keycloak.service.type | string | `"ClusterIP"` | keycloak.service.type is the type of Kubernetes service. |
| keycloak.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | keycloak.serviceAccount defines the Kubernetes service account used by the Keycloak pod. |
| keycloak.serviceAccount.annotations | object | `{}` | keycloak.serviceAccount.annotations defines annotations to add to the service account. |
| keycloak.serviceAccount.create | bool | `false` | keycloak.serviceAccount.create determines whether to create a new service account. |
| keycloak.serviceAccount.name | string | `""` | keycloak.serviceAccount.name is the name of the service account to use. |
| keycloak.tolerations | list | `[]` | keycloak.tolerations defines tolerations for the Keycloak pods. |
| nameOverride | string | `""` | Override name of app |
| networkPolicy.denyAll | bool | `false` | networkPolicy.denyAll defines whether to apply denyAll network policy |
| networkPolicy.enabled | bool | `false` | networkPolicy.enabled specifies whether to enable network policies |
| networkPolicy.nodeCIDR | list | `[]` | networkPolicy.nodeCIDR allows for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes |
| podLabels | object | `{}` | podLabels defines labels to add to all Studio pod(s) |
| rasa | object | `{"enabled":true,"fullnameOverride":"rasapro","rasa":{"command":["python","-m","rasa.model_service"],"envFrom":[{"configMapRef":{"name":"shared-environment"}}],"image":{"repository":"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro","tag":"3.12.6-latest"},"ingress":{"annotations":{},"enabled":true,"hosts":[{"host":"INGRESS.HOST.NAME","paths":[{"path":"/talk","pathType":"Prefix"}]}]},"livenessProbe":{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8000,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5},"overrideEnv":[{"name":"RASA_PRO_LICENSE","valueFrom":{"secretKeyRef":{"key":"RASA_PRO_LICENSE_SECRET_KEY","name":"studio-secrets"}}},{"name":"OPENAI_API_KEY","valueFrom":{"secretKeyRef":{"key":"OPENAI_API_KEY_SECRET_KEY","name":"studio-secrets"}}}],"persistence":{"create":true,"hostPath":{"enabled":false},"storageCapacity":"1Gi","storageClassName":null,"storageRequests":"1Gi"},"podSecurityContext":{"fsGroup":1001},"readinessProbe":{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8000,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5},"replicaCount":1,"resources":{},"service":{"port":80,"targetPort":8000},"settings":{"mountDefaultConfigmap":false,"useDefaultArgs":false},"strategy":{"type":"Recreate"}},"rasaProServices":{"enabled":false}}` | Define the resources for the Rasa Pro model server |
| rasa.rasa.ingress.hosts[0] | object | `{"host":"INGRESS.HOST.NAME","paths":[{"path":"/talk","pathType":"Prefix"}]}` | Please update the below URL with the correct host name of the Studio deployment |
| rasa.rasa.persistence.storageClassName | string | `nil` | Make sure to set the correct storage class name based on your cluster configuration |
| rasa.rasa.podSecurityContext.fsGroup | int | `1001` | User ID of the container to access the mounted volume |
| rasa.rasa.resources | object | `{}` | rasa.resources specifies the resources limits and requests |
| replicated.enabled | bool | `false` |  |
| replicated.sdkVersion | string | `"1.5.2"` |  |
| repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/studio/"` | repository specifies image repository for Studio |
| tag | string | `"1.12.2"` | tag specifies image tag for Studio # Overrides the image tag whose default is the chart appVersion. |
| webClient.additionalContainers | list | `[]` | webClient.additionalContainers defines additional containers to run alongside the main Web Client container. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] |
| webClient.affinity | object | `{}` | webClient.affinity defines affinity rules for the web client pods. |
| webClient.envFrom | list | `[]` | webClient.envFrom defines additional environment variables from ConfigMap or Secret. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret |
| webClient.environmentVariables | object | `{"KEYCLOAK_CLIENT_ID":"rasa-studio-backend","KEYCLOAK_REALM":"rasa-studio"}` | webClient.environmentVariables defines the environment variables for the Web Client deployment. Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. |
| webClient.environmentVariables.KEYCLOAK_CLIENT_ID | string | `"rasa-studio-backend"` | webClient.environmentVariables.KEYCLOAK_CLIENT_ID is the Keycloak client ID for the web client. |
| webClient.environmentVariables.KEYCLOAK_REALM | string | `"rasa-studio"` | webClient.environmentVariables.KEYCLOAK_REALM is the Keycloak realm name for Studio. |
| webClient.image | object | `{"name":"studio-web-client","pullPolicy":"IfNotPresent"}` | webClient.image defines the container image settings for the web client service. |
| webClient.image.name | string | `"studio-web-client"` | webClient.image.name is the name of the Web Client container image. |
| webClient.image.pullPolicy | string | `"IfNotPresent"` | webClient.image.pullPolicy is the container image pull policy. |
| webClient.ingress | object | `{"additionalAnnotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` | webClient.ingress defines how the web client service is exposed externally. |
| webClient.ingress.additionalAnnotations | object | `{}` | webClient.ingress.additionalAnnotations defines additional annotations for the ingress resource. |
| webClient.ingress.className | string | `""` | webClient.ingress.className is the ingress class name. |
| webClient.ingress.enabled | bool | `true` | webClient.ingress.enabled determines whether to create an ingress resource. |
| webClient.ingress.labels | object | `{}` | webClient.ingress.labels defines labels to add to the ingress resource. |
| webClient.ingress.tls | list | `[]` | webClient.ingress.tls defines the TLS configuration for the ingress. |
| webClient.livenessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8080,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | webClient.livenessProbe defines the liveness probe configuration. |
| webClient.livenessProbe.enabled | bool | `true` | webClient.livenessProbe.enabled determines whether to enable the liveness probe. |
| webClient.livenessProbe.failureThreshold | int | `6` | webClient.livenessProbe.failureThreshold is the number of failures before the container is considered unhealthy. |
| webClient.livenessProbe.httpGet | object | `{"path":"/","port":8080,"scheme":"HTTP"}` | webClient.livenessProbe.httpGet defines the HTTP GET probe configuration. |
| webClient.livenessProbe.httpGet.path | string | `"/"` | webClient.livenessProbe.httpGet.path is the path to check for liveness. |
| webClient.livenessProbe.httpGet.port | int | `8080` | webClient.livenessProbe.httpGet.port is the port to check for liveness. |
| webClient.livenessProbe.httpGet.scheme | string | `"HTTP"` | webClient.livenessProbe.httpGet.scheme is the protocol to use for the check. |
| webClient.livenessProbe.initialDelaySeconds | int | `15` | webClient.livenessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. |
| webClient.livenessProbe.periodSeconds | int | `15` | webClient.livenessProbe.periodSeconds is how often to perform the probe. |
| webClient.livenessProbe.successThreshold | int | `1` | webClient.livenessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. |
| webClient.livenessProbe.timeoutSeconds | int | `5` | webClient.livenessProbe.timeoutSeconds is the number of seconds after which the probe times out. |
| webClient.nodeSelector | object | `{}` | webClient.nodeSelector defines which nodes the web client pods can run on. |
| webClient.podAnnotations | object | `{}` | webClient.podAnnotations defines annotations to add to the web client pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-web-client: runtime/default |
| webClient.podSecurityContext | object | `{"enabled":true}` | webClient.podSecurityContext defines the security settings for the entire pod. |
| webClient.podSecurityContext.enabled | bool | `true` | webClient.podSecurityContext.enabled determines whether to enable the pod security context. |
| webClient.readinessProbe | object | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8080,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | webClient.readinessProbe defines the readiness probe configuration. |
| webClient.readinessProbe.enabled | bool | `true` | webClient.readinessProbe.enabled determines whether to enable the readiness probe. |
| webClient.readinessProbe.failureThreshold | int | `6` | webClient.readinessProbe.failureThreshold is the number of failures before the container is considered not ready. |
| webClient.readinessProbe.httpGet | object | `{"path":"/","port":8080,"scheme":"HTTP"}` | webClient.readinessProbe.httpGet defines the HTTP GET probe configuration. |
| webClient.readinessProbe.httpGet.path | string | `"/"` | webClient.readinessProbe.httpGet.path is the path to check for readiness. |
| webClient.readinessProbe.httpGet.port | int | `8080` | webClient.readinessProbe.httpGet.port is the port to check for readiness. |
| webClient.readinessProbe.httpGet.scheme | string | `"HTTP"` | webClient.readinessProbe.httpGet.scheme is the protocol to use for the check. |
| webClient.readinessProbe.initialDelaySeconds | int | `15` | webClient.readinessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. |
| webClient.readinessProbe.periodSeconds | int | `15` | webClient.readinessProbe.periodSeconds is how often to perform the probe. |
| webClient.readinessProbe.successThreshold | int | `1` | webClient.readinessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. |
| webClient.readinessProbe.timeoutSeconds | int | `5` | webClient.readinessProbe.timeoutSeconds is the number of seconds after which the probe times out. |
| webClient.replicaCount | int | `1` | webClient.replicaCount is the number of replicas for the Web Client deployment. |
| webClient.resources | object | `{}` | webClient.resources defines the resource limits and requests for the web client. |
| webClient.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` | webClient.securityContext defines the security settings for the web client container. |
| webClient.securityContext.allowPrivilegeEscalation | bool | `false` | webClient.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. |
| webClient.securityContext.capabilities | object | `{"drop":["ALL"]}` | webClient.securityContext.capabilities defines the Linux capabilities configuration. |
| webClient.securityContext.capabilities.drop | list | `["ALL"]` | webClient.securityContext.capabilities.drop defines capabilities to drop from the container. |
| webClient.securityContext.enabled | bool | `true` | webClient.securityContext.enabled determines whether to enable the security context. |
| webClient.securityContext.runAsNonRoot | bool | `true` | webClient.securityContext.runAsNonRoot determines whether to run the container as a non-root user. |
| webClient.service | object | `{"port":80,"targetPort":8080,"type":"ClusterIP"}` | webClient.service defines how the web client service is exposed within the cluster. |
| webClient.service.port | int | `80` | webClient.service.port is the port number for the service. |
| webClient.service.targetPort | int | `8080` | webClient.service.targetPort is the target port in the container. |
| webClient.service.type | string | `"ClusterIP"` | webClient.service.type is the type of Kubernetes service. |
| webClient.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | webClient.serviceAccount defines the Kubernetes service account used by the web client pod. |
| webClient.serviceAccount.annotations | object | `{}` | webClient.serviceAccount.annotations defines annotations to add to the service account. |
| webClient.serviceAccount.create | bool | `false` | webClient.serviceAccount.create determines whether to create a new service account. |
| webClient.serviceAccount.name | string | `""` | webClient.serviceAccount.name is the name of the service account to use. |
| webClient.tolerations | list | `[]` | webClient.tolerations defines tolerations for the web client pods. |
