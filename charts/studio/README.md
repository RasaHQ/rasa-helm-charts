# studio

A Rasa Studio Helm chart for Kubernetes

![Version: 2.2.3](https://img.shields.io/badge/Version-2.2.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+

## Installing the Chart

You can install the chart from either the OCI registry or the GitHub Helm repository.

### Option 1: Install from OCI Registry

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 2.2.3
```

### Option 2: Install from GitHub Helm Repository

First, add the Rasa Helm repository:

```console
$ helm repo add rasa https://helm.rasa.com/charts
$ helm repo update
```

Then install the chart:

```console
$ helm install my-release rasa/studio --version 2.2.3
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Pull the Chart

You can pull the chart from either source:

### From OCI Registry:

```console
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 2.2.3
```

### From GitHub Helm Repository:

```console
$ helm pull rasa/studio --version 2.2.3
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

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| backend.additionalContainers | list | backend.additionalContainers defines additional containers to run alongside the main Studio Backend container. These containers will be part of the same pod and share the pod's network namespace. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] Ref: https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers | `[]` |
| backend.affinity | object | backend.affinity defines affinity rules for the backend pods. This controls where the pods can be scheduled. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| backend.annotations | object | backend.annotations defines annotations to add to all Studio Backend resources. These annotations will be merged with deploymentAnnotations (deploymentAnnotations take precedence if keys conflict). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| backend.autoscaling | object | backend.autoscaling defines the Horizontal Pod Autoscaling configuration. This enables automatic scaling of the backend deployment based on metrics. Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/ | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` |
| backend.autoscaling.enabled | bool | backend.autoscaling.enabled determines whether to enable horizontal pod autoscaling. | `false` |
| backend.autoscaling.maxReplicas | int | backend.autoscaling.maxReplicas is the maximum number of replicas. | `100` |
| backend.autoscaling.minReplicas | int | backend.autoscaling.minReplicas is the minimum number of replicas. | `1` |
| backend.autoscaling.targetCPUUtilizationPercentage | int | backend.autoscaling.targetCPUUtilizationPercentage is the target CPU utilization percentage. The HPA will scale the deployment to maintain this CPU utilization. Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details | `80` |
| backend.envFrom | list | backend.envFrom defines additional environment variables from ConfigMap or Secret. These will be mounted as environment variables in the container. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables | `[]` |
| backend.environmentVariables | object | backend.environmentVariables defines the environment variables for the Studio Backend deployment. These variables configure the runtime behavior of the backend service. Each variable can be set either directly with a value or from a Kubernetes secret. Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. Ref: https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/ | `{"DELETE_CONVERSATIONS_CRON_EXPRESSION":{"value":"0 * * * *"},"DELETE_CONVERSATIONS_OLDER_THAN_HOURS":{"value":""}}` |
| backend.environmentVariables.DELETE_CONVERSATIONS_CRON_EXPRESSION | object | backend.environmentVariables.DELETE_CONVERSATIONS_CRON_EXPRESSION is the cron schedule for conversation cleanup job. Format: "minute hour day-of-month month day-of-week" Example: "0 * * * *" runs every hour Default: Runs every hour at minute 0 Ref: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax | `{"value":"0 * * * *"}` |
| backend.environmentVariables.DELETE_CONVERSATIONS_OLDER_THAN_HOURS | object | backend.environmentVariables.DELETE_CONVERSATIONS_OLDER_THAN_HOURS is the conversation data retention period in hours. Conversations older than this value will be deleted by the cleanup cron job. Leave empty to disable automatic conversation cleanup. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/ | `{"value":""}` |
| backend.image | object | backend.image defines the container image settings for the backend service. This section defines the container image settings for the backend service. Ref: https://kubernetes.io/docs/concepts/containers/images/ | `{"name":"studio-backend","pullPolicy":"IfNotPresent"}` |
| backend.image.name | string | backend.image.name is the name of the Studio Backend container image. This should match the image name in your container registry. | `"studio-backend"` |
| backend.image.pullPolicy | string | backend.image.pullPolicy is the container image pull policy. Valid values: Always, IfNotPresent, Never Always: Always pull the image IfNotPresent: Only pull if not present locally Never: Never pull the image Ref: https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy | `"IfNotPresent"` |
| backend.ingress | object | backend.ingress defines how the backend service is exposed externally. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/ | `{"additionalAnnotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` |
| backend.ingress.additionalAnnotations | object | backend.ingress.additionalAnnotations defines additional annotations for the ingress resource. Example:   kubernetes.io/ingress.class: nginx   cert-manager.io/cluster-issuer: letsencrypt-prod Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| backend.ingress.className | string | backend.ingress.className is the ingress class name. This should match your cluster's ingress controller. Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class | `""` |
| backend.ingress.enabled | bool | backend.ingress.enabled determines whether to create an ingress resource. | `true` |
| backend.ingress.labels | object | backend.ingress.labels defines labels to add to the ingress resource. Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ | `{}` |
| backend.ingress.tls | list | backend.ingress.tls defines the TLS configuration for the ingress. Example: - secretName: chart-example-tls   hosts:     - chart-example.local | `[]` |
| backend.livenessProbe | object | backend.livenessProbe defines the liveness probe configuration. This determines if the container is alive and functioning. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| backend.livenessProbe.enabled | bool | backend.livenessProbe.enabled determines whether to enable the liveness probe. | `true` |
| backend.livenessProbe.failureThreshold | int | backend.livenessProbe.failureThreshold is the number of failures before the container is considered unhealthy. | `6` |
| backend.livenessProbe.httpGet | object | backend.livenessProbe.httpGet defines the HTTP GET probe configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command | `{"path":"/api/health","port":4000,"scheme":"HTTP"}` |
| backend.livenessProbe.httpGet.path | string | backend.livenessProbe.httpGet.path is the path to check for liveness. | `"/api/health"` |
| backend.livenessProbe.httpGet.port | int | backend.livenessProbe.httpGet.port is the port to check for liveness. | `4000` |
| backend.livenessProbe.httpGet.scheme | string | backend.livenessProbe.httpGet.scheme is the protocol to use for the check. | `"HTTP"` |
| backend.livenessProbe.initialDelaySeconds | int | backend.livenessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. | `15` |
| backend.livenessProbe.periodSeconds | int | backend.livenessProbe.periodSeconds is how often to perform the probe. | `15` |
| backend.livenessProbe.successThreshold | int | backend.livenessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. | `1` |
| backend.livenessProbe.timeoutSeconds | int | backend.livenessProbe.timeoutSeconds is the number of seconds after which the probe times out. | `5` |
| backend.migration | object | backend.migration defines the database migration job configuration. This section controls the database schema migration process. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/job/ | `{"affinity":{},"annotations":{},"enabled":true,"environmentVariables":{"KC_DEFAULT_DATABASE_CONNECTION_NAME":{"value":"postgres"},"SKIP_KEYCLOAK":{"value":"false"}},"image":{"name":"studio-database-migration","pullPolicy":"IfNotPresent"},"nodeSelector":{},"podAnnotations":{},"serviceAccount":{"annotations":{},"create":false,"name":""},"tolerations":[],"waitForIt":false,"waitFotItContainer":{"image":"postgres:17.2"}}` |
| backend.migration.affinity | object | backend.migration.affinity defines affinity rules for the migration job. This controls where the job can be scheduled. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| backend.migration.annotations | object | backend.migration.annotations defines annotations to add to the migration job resource. These annotations will be merged with deploymentAnnotations and helm hook annotations (helm hooks take precedence). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| backend.migration.enabled | bool | backend.migration.enabled determines whether to enable the database migration job. Set to false if you want to handle migrations manually. | `true` |
| backend.migration.environmentVariables | object | backend.migration.environmentVariables defines the environment variables for the migration job. Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. | `{"KC_DEFAULT_DATABASE_CONNECTION_NAME":{"value":"postgres"},"SKIP_KEYCLOAK":{"value":"false"}}` |
| backend.migration.environmentVariables.KC_DEFAULT_DATABASE_CONNECTION_NAME | object | backend.migration.environmentVariables.KC_DEFAULT_DATABASE_CONNECTION_NAME is the name of the database used to client will connect to when creating the keycloak database. if your database does not have a `postgres` database, you can set this to the name of the database you want the client to connect to when creating the keycloak database. | `{"value":"postgres"}` |
| backend.migration.environmentVariables.SKIP_KEYCLOAK | object | backend.migration.environmentVariables.SKIP_KEYCLOAK determines whether to skip Keycloak database creation. Set to "true" if you have already created the Keycloak database manually. | `{"value":"false"}` |
| backend.migration.image | object | backend.migration.image defines the image configuration for the migration job. | `{"name":"studio-database-migration","pullPolicy":"IfNotPresent"}` |
| backend.migration.image.name | string | backend.migration.image.name is the name of the migration container image. | `"studio-database-migration"` |
| backend.migration.image.pullPolicy | string | backend.migration.image.pullPolicy is the container image pull policy. | `"IfNotPresent"` |
| backend.migration.nodeSelector | object | backend.migration.nodeSelector defines which nodes the migration job can run on. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector | `{}` |
| backend.migration.podAnnotations | object | backend.migration.podAnnotations defines annotations to add to the migration job pod. Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| backend.migration.serviceAccount | object | backend.migration.serviceAccount defines the Kubernetes service account used by the migration job pod. | `{"annotations":{},"create":false,"name":""}` |
| backend.migration.serviceAccount.annotations | object | backend.migration.serviceAccount.annotations defines annotations to add to the service account. | `{}` |
| backend.migration.serviceAccount.create | bool | backend.migration.serviceAccount.create determines whether to create a new service account. | `false` |
| backend.migration.serviceAccount.name | string | backend.migration.serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname + "-db-migration" suffix. | `""` |
| backend.migration.tolerations | list | backend.migration.tolerations defines tolerations for the migration job. This allows the job to run on nodes with matching taints. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ | `[]` |
| backend.migration.waitForIt | bool | backend.migration.waitForIt determines whether to wait for the database to be ready before running migrations. | `false` |
| backend.migration.waitFotItContainer | object | backend.migration.waitFotItContainer defines the configuration for the wait-for-it container. | `{"image":"postgres:17.2"}` |
| backend.nodeSelector | object | backend.nodeSelector defines which nodes the backend pods can run on. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector | `{}` |
| backend.podAnnotations | object | backend.podAnnotations defines annotations to add to the backend pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-backend: runtime/default Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| backend.podSecurityContext | object | backend.podSecurityContext defines the security settings for the entire pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ | `{"enabled":true}` |
| backend.podSecurityContext.enabled | bool | backend.podSecurityContext.enabled determines whether to enable the pod security context. | `true` |
| backend.readinessProbe | object | backend.readinessProbe defines the readiness probe configuration. This determines if the container is ready to receive traffic. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/api/health","port":4000,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| backend.readinessProbe.enabled | bool | backend.readinessProbe.enabled determines whether to enable the readiness probe. | `true` |
| backend.readinessProbe.failureThreshold | int | backend.readinessProbe.failureThreshold is the number of failures before the container is considered not ready. | `6` |
| backend.readinessProbe.httpGet | object | backend.readinessProbe.httpGet defines the HTTP GET probe configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-readiness-probe | `{"path":"/api/health","port":4000,"scheme":"HTTP"}` |
| backend.readinessProbe.httpGet.path | string | backend.readinessProbe.httpGet.path is the path to check for readiness. | `"/api/health"` |
| backend.readinessProbe.httpGet.port | int | backend.readinessProbe.httpGet.port is the port to check for readiness. | `4000` |
| backend.readinessProbe.httpGet.scheme | string | backend.readinessProbe.httpGet.scheme is the protocol to use for the check. | `"HTTP"` |
| backend.readinessProbe.initialDelaySeconds | int | backend.readinessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. | `15` |
| backend.readinessProbe.periodSeconds | int | backend.readinessProbe.periodSeconds is how often to perform the probe. | `15` |
| backend.readinessProbe.successThreshold | int | backend.readinessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. | `1` |
| backend.readinessProbe.timeoutSeconds | int | backend.readinessProbe.timeoutSeconds is the number of seconds after which the probe times out. | `5` |
| backend.replicaCount | int | backend.replicaCount is the number of replicas for the Studio Backend deployment. Increase this value for high availability and better load distribution. Ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#replicas | `1` |
| backend.resources | object | backend.resources defines the resource limits and requests for Studio Backend. This controls the compute resources allocated to the backend container. Ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ | `{}` |
| backend.securityContext | object | backend.securityContext defines the security settings for the backend container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` |
| backend.securityContext.allowPrivilegeEscalation | bool | backend.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. Should be false for security best practices. | `false` |
| backend.securityContext.capabilities | object | backend.securityContext.capabilities defines the Linux capabilities configuration. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container | `{"drop":["ALL"]}` |
| backend.securityContext.capabilities.drop | list | backend.securityContext.capabilities.drop defines capabilities to drop from the container. ALL drops all capabilities for maximum security. | `["ALL"]` |
| backend.securityContext.enabled | bool | backend.securityContext.enabled determines whether to enable the security context. | `true` |
| backend.securityContext.runAsNonRoot | bool | backend.securityContext.runAsNonRoot determines whether to run the container as a non-root user. Should be true for security best practices. | `true` |
| backend.service | object | backend.service defines how the backend service is exposed within the cluster. Ref: https://kubernetes.io/docs/concepts/services-networking/service/ | `{"port":80,"targetPort":4000,"type":"ClusterIP"}` |
| backend.service.port | int | backend.service.port is the port number for the service. | `80` |
| backend.service.targetPort | int | backend.service.targetPort is the target port in the container. This should match the port your application listens on. | `4000` |
| backend.service.type | string | backend.service.type is the type of Kubernetes service. Valid values: ClusterIP, NodePort, LoadBalancer, ExternalName Ref: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types | `"ClusterIP"` |
| backend.serviceAccount | object | backend.serviceAccount defines the Kubernetes service account used by the backend pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ | `{"annotations":{},"create":false,"name":""}` |
| backend.serviceAccount.annotations | object | backend.serviceAccount.annotations defines annotations to add to the service account. Useful for cloud provider specific configurations. | `{}` |
| backend.serviceAccount.create | bool | backend.serviceAccount.create determines whether to create a new service account. | `false` |
| backend.serviceAccount.name | string | backend.serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template. | `""` |
| backend.tolerations | list | backend.tolerations defines tolerations for the backend pods. This allows the pods to run on nodes with matching taints. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ | `[]` |
| config.affinity | object | Pod affinity and anti-affinity rules for all deployments. These settings can be overridden by component-specific configurations. | `{}` |
| config.connectionType | string | Define if you will be using https or http with the ingressHost. Valid values are "http" or "https". This setting affects how services communicate with each other. | `"http"` |
| config.database | object | The postgres database instance details for Studio to connect to. This section configures the database connection parameters for Studio. | `{"awsRegion":"","backendDatabaseName":"studio","host":"","iamDbUsername":"","keycloakDatabaseName":"keycloak","password":{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"},"port":"5432","preferSSL":"true","queryParams":"","rejectUnauthorized":"","useAwsIamAuth":"","username":""}` |
| config.database.awsRegion | string | The AWS region for the database. Needed if you want to use AWS IAM authentication for the database. | `""` |
| config.database.backendDatabaseName | string | The database name for Studio backend services. This is used by Studio to store its data. | `"studio"` |
| config.database.host | string | The database host name or IP address where PostgreSQL is running. Example: "postgres.example.com" or "10.0.0.1" | `""` |
| config.database.iamDbUsername | string | The IAM database username for the database. Needed if you want to use AWS IAM authentication for the database. | `""` |
| config.database.keycloakDatabaseName | string | The database name for Keycloak user management service. This is used by Keycloak to store its user management data. | `"keycloak"` |
| config.database.password | object | The database password configuration. This references a Kubernetes secret containing the database password. | `{"secretKey":"DATABASE_PASSWORD","secretName":"studio-secrets"}` |
| config.database.port | string | The database port number for PostgreSQL. Default PostgreSQL port is 5432 | `"5432"` |
| config.database.preferSSL | string | Set to true if you want to use SSL for database connection. When enabled, Studio will attempt to establish an encrypted connection to the database. | `"true"` |
| config.database.queryParams | string | The database connection URL query parameters. These parameters are used to configure the database connection. Example: "sslmode=require&connect_timeout=30" | `""` |
| config.database.rejectUnauthorized | string | If true, the server will reject database connections which are not present in the list of supplied CAs. This provides additional security by ensuring only trusted certificates are accepted. | `""` |
| config.database.useAwsIamAuth | string | Set to true if you want to use AWS IAM authentication for the database. | `""` |
| config.database.username | string | The database username for Studio to connect with. This user should have appropriate permissions on the database. | `""` |
| config.ingressAnnotations | object | Define the ingress annotations to be used for ALL the ingress resources. These annotations will be applied to all ingress resources created by this chart. Example:   kubernetes.io/ingress.class: nginx   cert-manager.io/cluster-issuer: letsencrypt-prod | `{}` |
| config.ingressClassName | string | Define the ingress class name to be used for ALL the ingress resources. This value will be applied to all ingress resources created by this chart. Example: "nginx", "istio", "traefik" Ref: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class | `""` |
| config.ingressHost | string | Defines the host name for all Studio ingress resources. This value is used as an anchor (&dns_hostname) for referencing the host name across multiple places in the Helm chart. WARNING: Do NOT delete or modify the anchor (&dns_hostname) as it is critical for the proper functioning of the chart. If you need to update the host name, only change the value (INGRESS.HOST.NAME), keeping the anchor intact. | `"INGRESS.HOST.NAME"` |
| config.keycloak | object | config.keycloak defines the Keycloak configuration settings. This section configures the authentication and authorization service. | `{"adminPassword":{"secretKey":"KEYCLOAK_ADMIN_PASSWORD","secretName":"studio-secrets"},"adminUsername":"kcadmin","apiClientId":"admin-cli","apiPassword":{"secretKey":"KEYCLOAK_API_PASSWORD","secretName":"studio-secrets"},"apiUsername":"realmadmin","clientId":"rasa-studio-backend","realm":"rasa-studio","url":""}` |
| config.keycloak.adminPassword | object | config.keycloak.adminPassword defines the admin password for Keycloak. This password is used to login to the Keycloak admin console. The password is stored in a Kubernetes secret. | `{"secretKey":"KEYCLOAK_ADMIN_PASSWORD","secretName":"studio-secrets"}` |
| config.keycloak.adminUsername | string | config.keycloak.adminUsername is the admin username for Keycloak. This username is used to login to the Keycloak admin console. | `"kcadmin"` |
| config.keycloak.apiClientId | string | config.keycloak.apiClientId is the client ID for Keycloak API. This client is used by Studio Backend to authenticate with Keycloak. | `"admin-cli"` |
| config.keycloak.apiPassword | object | config.keycloak.apiPassword is the password for Keycloak API. This password is used by Studio Backend to authenticate with Keycloak. | `{"secretKey":"KEYCLOAK_API_PASSWORD","secretName":"studio-secrets"}` |
| config.keycloak.apiUsername | string | config.keycloak.apiUsername is the username for Keycloak API. This username is used by Studio Backend to authenticate with Keycloak. | `"realmadmin"` |
| config.keycloak.clientId | string | config.keycloak.clientId is the client ID for Keycloak. This client is used by Studio to authenticate with Keycloak. | `"rasa-studio-backend"` |
| config.keycloak.realm | string | config.keycloak.realm is the realm name for Keycloak. This realm is used by Studio to manage users and clients. | `"rasa-studio"` |
| config.keycloak.url | string | config.keycloak.url overrides the default service endpoint for Keycloak. Format is `http(s)://<ingressHost>/auth`. Required only if your cluster redirects internal HTTP traffic to HTTPS. | `""` |
| config.nodeSelector | object | Common pod scheduling configuration for all deployments. These settings can be overridden by component-specific configurations. Not possible to combine with component-specific configurations for each scheduling option. | `{}` |
| config.tolerations | list | Pod tolerations for all deployments. These settings can be overridden by component-specific configurations. | `[]` |
| deploymentAnnotations | object | deploymentAnnotations defines annotations to add to all Studio resources. These annotations are applied globally to all resources (Deployments, Services, Ingresses, Jobs, HPAs, ConfigMaps, ServiceAccounts). Component-specific annotations can override these values if keys conflict. Example:   key: "value" Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| deploymentLabels | object | deploymentLabels defines labels to add to all Studio deployment | `{}` |
| dnsConfig | object | dnsConfig specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config | `{}` |
| dnsPolicy | string | dnsPolicy specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy | `""` |
| eventIngestion.additionalContainers | list | eventIngestion.additionalContainers defines additional containers to run alongside the main Event Ingestion container. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] | `[]` |
| eventIngestion.affinity | object | eventIngestion.affinity defines affinity rules for the event ingestion pods. | `{}` |
| eventIngestion.annotations | object | eventIngestion.annotations defines annotations to add to all Studio Event Ingestion resources. These annotations will be merged with deploymentAnnotations (deploymentAnnotations take precedence if keys conflict). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| eventIngestion.autoscaling | object | eventIngestion.autoscaling defines the Horizontal Pod Autoscaling configuration. | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` |
| eventIngestion.autoscaling.enabled | bool | eventIngestion.autoscaling.enabled determines whether to enable horizontal pod autoscaling. | `false` |
| eventIngestion.autoscaling.maxReplicas | int | eventIngestion.autoscaling.maxReplicas is the maximum number of replicas. | `100` |
| eventIngestion.autoscaling.minReplicas | int | eventIngestion.autoscaling.minReplicas is the minimum number of replicas. | `1` |
| eventIngestion.autoscaling.targetCPUUtilizationPercentage | int | eventIngestion.autoscaling.targetCPUUtilizationPercentage is the target CPU utilization percentage. | `80` |
| eventIngestion.enabled | bool | eventIngestion.enabled determines whether to deploy the event ingestion component. | `true` |
| eventIngestion.envFrom | list | eventIngestion.envFrom defines additional environment variables from ConfigMap or Secret. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret | `[]` |
| eventIngestion.environmentVariables | object | eventIngestion.environmentVariables defines the environment variables for the Event Ingestion deployment. Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. | `{"KAFKA_BROKER_ADDRESS":{"value":""},"KAFKA_CA_FILE":{"value":""},"KAFKA_CERT_FILE":{"value":""},"KAFKA_CUSTOM_SSL":{"value":""},"KAFKA_DLQ_TOPIC":{"value":"rasa-events-dlq"},"KAFKA_ENABLE_SSL":{"value":""},"KAFKA_GROUP_ID":{"value":"studio"},"KAFKA_KEY_FILE":{"value":""},"KAFKA_REJECT_UNAUTHORIZED":{"value":""},"KAFKA_SASL_MECHANISM":{"value":""},"KAFKA_SASL_PASSWORD":{"secret":{"key":"KAFKA_SASL_PASSWORD","name":"studio-secrets"}},"KAFKA_SASL_USERNAME":{"value":""},"KAFKA_TOPIC":{"value":"rasa-events"},"NODE_TLS_REJECT_UNAUTHORIZED":{"value":""}}` |
| eventIngestion.environmentVariables.KAFKA_BROKER_ADDRESS | object | eventIngestion.environmentVariables.KAFKA_BROKER_ADDRESS is the address of the Kafka broker. | `{"value":""}` |
| eventIngestion.environmentVariables.KAFKA_CA_FILE | object | eventIngestion.environmentVariables.KAFKA_CA_FILE is the path to the CA certificate file for Kafka SSL. | `{"value":""}` |
| eventIngestion.environmentVariables.KAFKA_CERT_FILE | object | eventIngestion.environmentVariables.KAFKA_CERT_FILE is the path to the client certificate file for Kafka SSL. | `{"value":""}` |
| eventIngestion.environmentVariables.KAFKA_CUSTOM_SSL | object | eventIngestion.environmentVariables.KAFKA_CUSTOM_SSL determines whether to use custom SSL certificates for Kafka. | `{"value":""}` |
| eventIngestion.environmentVariables.KAFKA_DLQ_TOPIC | object | eventIngestion.environmentVariables.KAFKA_DLQ_TOPIC is the Kafka topic for unprocessed events. | `{"value":"rasa-events-dlq"}` |
| eventIngestion.environmentVariables.KAFKA_ENABLE_SSL | object | eventIngestion.environmentVariables.KAFKA_ENABLE_SSL determines whether to enable SSL for Kafka connections. | `{"value":""}` |
| eventIngestion.environmentVariables.KAFKA_GROUP_ID | object | eventIngestion.environmentVariables.KAFKA_GROUP_ID is the Kafka consumer group ID for Studio. | `{"value":"studio"}` |
| eventIngestion.environmentVariables.KAFKA_KEY_FILE | object | eventIngestion.environmentVariables.KAFKA_KEY_FILE is the path to the client key file for Kafka SSL. | `{"value":""}` |
| eventIngestion.environmentVariables.KAFKA_REJECT_UNAUTHORIZED | object | eventIngestion.environmentVariables.KAFKA_REJECT_UNAUTHORIZED determines whether to verify server certificates. | `{"value":""}` |
| eventIngestion.environmentVariables.KAFKA_SASL_MECHANISM | object | eventIngestion.environmentVariables.KAFKA_SASL_MECHANISM is the SASL mechanism for Kafka authentication. Supported values: plain, SCRAM-SHA-256, SCRAM-SHA-512 | `{"value":""}` |
| eventIngestion.environmentVariables.KAFKA_SASL_PASSWORD | object | eventIngestion.environmentVariables.KAFKA_SASL_PASSWORD is the SASL password for Kafka authentication. | `{"secret":{"key":"KAFKA_SASL_PASSWORD","name":"studio-secrets"}}` |
| eventIngestion.environmentVariables.KAFKA_SASL_USERNAME | object | eventIngestion.environmentVariables.KAFKA_SASL_USERNAME is the SASL username for Kafka authentication. | `{"value":""}` |
| eventIngestion.environmentVariables.KAFKA_TOPIC | object | eventIngestion.environmentVariables.KAFKA_TOPIC is the Kafka topic for Rasa Pro assistant events. | `{"value":"rasa-events"}` |
| eventIngestion.environmentVariables.NODE_TLS_REJECT_UNAUTHORIZED | object | eventIngestion.environmentVariables.NODE_TLS_REJECT_UNAUTHORIZED determines whether to allow untrusted certificates. | `{"value":""}` |
| eventIngestion.image | object | eventIngestion.image defines the container image settings for the event ingestion service. | `{"name":"studio-event-ingestion","pullPolicy":"IfNotPresent"}` |
| eventIngestion.image.name | string | eventIngestion.image.name is the name of the Event Ingestion container image. | `"studio-event-ingestion"` |
| eventIngestion.image.pullPolicy | string | eventIngestion.image.pullPolicy is the container image pull policy. | `"IfNotPresent"` |
| eventIngestion.nodeSelector | object | eventIngestion.nodeSelector defines which nodes the event ingestion pods can run on. | `{}` |
| eventIngestion.podAnnotations | object | eventIngestion.podAnnotations defines annotations to add to the event ingestion pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-event-ingestion: runtime/default | `{}` |
| eventIngestion.podSecurityContext | object | eventIngestion.podSecurityContext defines the security settings for the entire pod. | `{"enabled":true}` |
| eventIngestion.podSecurityContext.enabled | bool | eventIngestion.podSecurityContext.enabled determines whether to enable the pod security context. | `true` |
| eventIngestion.replicaCount | int | eventIngestion.replicaCount is the number of replicas for the Event Ingestion deployment. | `1` |
| eventIngestion.resources | object | eventIngestion.resources defines the resource limits and requests for the event ingestion service. | `{}` |
| eventIngestion.securityContext | object | eventIngestion.securityContext defines the security settings for the event ingestion container. | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` |
| eventIngestion.securityContext.allowPrivilegeEscalation | bool | eventIngestion.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. | `false` |
| eventIngestion.securityContext.capabilities | object | eventIngestion.securityContext.capabilities defines the Linux capabilities configuration. | `{"drop":["ALL"]}` |
| eventIngestion.securityContext.capabilities.drop | list | eventIngestion.securityContext.capabilities.drop defines capabilities to drop from the container. | `["ALL"]` |
| eventIngestion.securityContext.enabled | bool | eventIngestion.securityContext.enabled determines whether to enable the security context. | `true` |
| eventIngestion.securityContext.runAsNonRoot | bool | eventIngestion.securityContext.runAsNonRoot determines whether to run the container as a non-root user. | `true` |
| eventIngestion.serviceAccount | object | eventIngestion.serviceAccount defines the Kubernetes service account used by the event ingestion pod. | `{"annotations":{},"create":false,"name":""}` |
| eventIngestion.serviceAccount.annotations | object | eventIngestion.serviceAccount.annotations defines annotations to add to the service account. | `{}` |
| eventIngestion.serviceAccount.create | bool | eventIngestion.serviceAccount.create determines whether to create a new service account. | `false` |
| eventIngestion.serviceAccount.name | string | eventIngestion.serviceAccount.name is the name of the service account to use. | `""` |
| eventIngestion.tolerations | list | eventIngestion.tolerations defines tolerations for the event ingestion pods. | `[]` |
| eventIngestion.volumeMounts | list | eventIngestion.volumeMounts defines where to mount the volumes in the Event Ingestion container. Example: - name: config-volume   mountPath: /etc/config   readOnly: true | `[]` |
| eventIngestion.volumes | list | eventIngestion.volumes defines additional volumes for the Event Ingestion container. Example: - name: config-volume   configMap:     name: special-config | `[]` |
| fullnameOverride | string | Override the full qualified app name | `""` |
| global.additionalDeploymentLabels | object | global.additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ | `{}` |
| global.ingressHost | string |  | `nil` |
| hostNetwork | bool | Controls whether the pod may use the node network namespace | `false` |
| imagePullSecrets | list | imagePullSecret defines repository pull secrets | `[]` |
| keycloak.additionalContainers | list | keycloak.additionalContainers defines additional containers to run alongside the main Keycloak container. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] | `[]` |
| keycloak.affinity | object | keycloak.affinity defines affinity rules for the Keycloak pods. | `{}` |
| keycloak.annotations | object | keycloak.annotations defines annotations to add to all Studio Keycloak resources. These annotations will be merged with deploymentAnnotations (deploymentAnnotations take precedence if keys conflict). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| keycloak.database | object | The postgres database instance details for Keycloak to connect to. This section configures the database connection parameters for Keycloak. If not all fields are provided, the same values in the database section will be used, including the keycloakDatabaseName for the database name. | `{}` |
| keycloak.enabled | bool | keycloak.enabled determines whether to deploy the Keycloak authentication service. | `true` |
| keycloak.envFrom | list | keycloak.envFrom defines additional environment variables from ConfigMap or Secret. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret | `[]` |
| keycloak.environmentVariables | object | keycloak.environmentVariables defines the environment variables for the Keycloak deployment. Example: Specify the string value for variables   value: my-value Example: Specify the value for variables sourced from a Secret.   secret:     name: my-secret     key: my-secret-key NOTE: Helm will return an error if environment variable does not have `value` or `secret` provided. | `{"KC_HTTP_ENABLED":{"value":"true"},"KC_PROXY":{"value":"edge"},"KC_PROXY_HEADERS":{"value":"xforwarded"}}` |
| keycloak.environmentVariables.KC_HTTP_ENABLED | object | keycloak.environmentVariables.KC_HTTP_ENABLED determines the proxy configuration for Keycloak. Set to "true" to enable HTTP communication between proxy/load balancer and Keycloak. Useful for secure internal networks where the reverse proxy maintains HTTPS with clients. | `{"value":"true"}` |
| keycloak.environmentVariables.KC_PROXY | object | legacy keycloak value to enable HTTP communication between proxy/loadbalancer and Keycloak. This is deprecated (replaced by KC_HTTP_ENABLED) and will be removed in future releases. | `{"value":"edge"}` |
| keycloak.environmentVariables.KC_PROXY_HEADERS | object | keycloak.environmentVariables.KC_PROXY_HEADERS determines the proxy headers for Keycloak. Set to "xforwarded" to enable parsing of non-standard X-Forwarded-* headers, such as X-Forwarded-For, X-Forwarded-Proto, X-Forwarded-Host, and X-Forwarded-Port. https://www.keycloak.org/server/reverseproxy | `{"value":"xforwarded"}` |
| keycloak.image | object | keycloak.image defines the container image settings for the Keycloak service. | `{"name":"studio-keycloak","pullPolicy":"IfNotPresent"}` |
| keycloak.image.name | string | keycloak.image.name is the name of the Keycloak container image. | `"studio-keycloak"` |
| keycloak.image.pullPolicy | string | keycloak.image.pullPolicy is the container image pull policy. | `"IfNotPresent"` |
| keycloak.ingress | object | keycloak.ingress defines how the Keycloak service is exposed externally. | `{"additionalAnnotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` |
| keycloak.ingress.additionalAnnotations | object | keycloak.ingress.additionalAnnotations defines additional annotations for the ingress resource. | `{}` |
| keycloak.ingress.className | string | keycloak.ingress.className is the ingress class name. | `""` |
| keycloak.ingress.enabled | bool | keycloak.ingress.enabled determines whether to create an ingress resource. | `true` |
| keycloak.ingress.labels | object | keycloak.ingress.labels defines labels to add to the ingress resource. | `{}` |
| keycloak.ingress.tls | list | keycloak.ingress.tls defines the TLS configuration for the ingress. | `[]` |
| keycloak.livenessProbe | object | keycloak.livenessProbe defines the liveness probe configuration. | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/auth","port":8080,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| keycloak.livenessProbe.enabled | bool | keycloak.livenessProbe.enabled determines whether to enable the liveness probe. | `true` |
| keycloak.livenessProbe.failureThreshold | int | keycloak.livenessProbe.failureThreshold is the number of failures before the container is considered unhealthy. | `6` |
| keycloak.livenessProbe.httpGet | object | keycloak.livenessProbe.httpGet defines the HTTP GET probe configuration. | `{"path":"/auth","port":8080,"scheme":"HTTP"}` |
| keycloak.livenessProbe.httpGet.path | string | keycloak.livenessProbe.httpGet.path is the path to check for liveness. | `"/auth"` |
| keycloak.livenessProbe.httpGet.port | int | keycloak.livenessProbe.httpGet.port is the port to check for liveness. | `8080` |
| keycloak.livenessProbe.httpGet.scheme | string | keycloak.livenessProbe.httpGet.scheme is the protocol to use for the check. | `"HTTP"` |
| keycloak.livenessProbe.initialDelaySeconds | int | keycloak.livenessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. | `30` |
| keycloak.livenessProbe.periodSeconds | int | keycloak.livenessProbe.periodSeconds is how often to perform the probe. | `15` |
| keycloak.livenessProbe.successThreshold | int | keycloak.livenessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. | `1` |
| keycloak.livenessProbe.timeoutSeconds | int | keycloak.livenessProbe.timeoutSeconds is the number of seconds after which the probe times out. | `5` |
| keycloak.nodeSelector | object | keycloak.nodeSelector defines which nodes the Keycloak pods can run on. | `{}` |
| keycloak.podAnnotations | object | keycloak.podAnnotations defines annotations to add to the Keycloak pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-keycloak: runtime/default | `{}` |
| keycloak.podSecurityContext | object | keycloak.podSecurityContext defines the security settings for the entire pod. | `{"enabled":true}` |
| keycloak.podSecurityContext.enabled | bool | keycloak.podSecurityContext.enabled determines whether to enable the pod security context. | `true` |
| keycloak.readinessProbe | object | keycloak.readinessProbe defines the readiness probe configuration. | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/auth","port":8080,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| keycloak.readinessProbe.enabled | bool | keycloak.readinessProbe.enabled determines whether to enable the readiness probe. | `true` |
| keycloak.readinessProbe.failureThreshold | int | keycloak.readinessProbe.failureThreshold is the number of failures before the container is considered not ready. | `6` |
| keycloak.readinessProbe.httpGet | object | keycloak.readinessProbe.httpGet defines the HTTP GET probe configuration. | `{"path":"/auth","port":8080,"scheme":"HTTP"}` |
| keycloak.readinessProbe.httpGet.path | string | keycloak.readinessProbe.httpGet.path is the path to check for readiness. | `"/auth"` |
| keycloak.readinessProbe.httpGet.port | int | keycloak.readinessProbe.httpGet.port is the port to check for readiness. | `8080` |
| keycloak.readinessProbe.httpGet.scheme | string | keycloak.readinessProbe.httpGet.scheme is the protocol to use for the check. | `"HTTP"` |
| keycloak.readinessProbe.initialDelaySeconds | int | keycloak.readinessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. | `30` |
| keycloak.readinessProbe.periodSeconds | int | keycloak.readinessProbe.periodSeconds is how often to perform the probe. | `15` |
| keycloak.readinessProbe.successThreshold | int | keycloak.readinessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. | `1` |
| keycloak.readinessProbe.timeoutSeconds | int | keycloak.readinessProbe.timeoutSeconds is the number of seconds after which the probe times out. | `5` |
| keycloak.replicaCount | int | keycloak.replicaCount is the number of replicas for the Keycloak deployment. | `1` |
| keycloak.resources | object | keycloak.resources defines the resource limits and requests for the Keycloak service. | `{}` |
| keycloak.securityContext | object | keycloak.securityContext defines the security settings for the Keycloak container. | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` |
| keycloak.securityContext.allowPrivilegeEscalation | bool | keycloak.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. | `false` |
| keycloak.securityContext.capabilities | object | keycloak.securityContext.capabilities defines the Linux capabilities configuration. | `{"drop":["ALL"]}` |
| keycloak.securityContext.capabilities.drop | list | keycloak.securityContext.capabilities.drop defines capabilities to drop from the container. | `["ALL"]` |
| keycloak.securityContext.enabled | bool | keycloak.securityContext.enabled determines whether to enable the security context. | `true` |
| keycloak.securityContext.runAsNonRoot | bool | keycloak.securityContext.runAsNonRoot determines whether to run the container as a non-root user. | `true` |
| keycloak.service | object | keycloak.service defines how the Keycloak service is exposed within the cluster. | `{"port":80,"targetPort":8080,"type":"ClusterIP"}` |
| keycloak.service.port | int | keycloak.service.port is the port number for the service. | `80` |
| keycloak.service.targetPort | int | keycloak.service.targetPort is the target port in the container. | `8080` |
| keycloak.service.type | string | keycloak.service.type is the type of Kubernetes service. | `"ClusterIP"` |
| keycloak.serviceAccount | object | keycloak.serviceAccount defines the Kubernetes service account used by the Keycloak pod. | `{"annotations":{},"create":false,"name":""}` |
| keycloak.serviceAccount.annotations | object | keycloak.serviceAccount.annotations defines annotations to add to the service account. | `{}` |
| keycloak.serviceAccount.create | bool | keycloak.serviceAccount.create determines whether to create a new service account. | `false` |
| keycloak.serviceAccount.name | string | keycloak.serviceAccount.name is the name of the service account to use. | `""` |
| keycloak.tolerations | list | keycloak.tolerations defines tolerations for the Keycloak pods. | `[]` |
| nameOverride | string | Override name of app | `""` |
| networkPolicy.denyAll | bool | networkPolicy.denyAll defines whether to apply denyAll network policy | `false` |
| networkPolicy.enabled | bool | networkPolicy.enabled specifies whether to enable network policies | `false` |
| networkPolicy.nodeCIDR | list | networkPolicy.nodeCIDR allows for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes | `[]` |
| podLabels | object | podLabels defines labels to add to all Studio pod(s) | `{}` |
| rasa | object | Define the resources for the Rasa Pro model server | `{"enabled":true,"fullnameOverride":"rasapro","rasa":{"command":["python","-m","rasa.model_service"],"envFrom":[{"configMapRef":{"name":"shared-environment"}}],"image":{"repository":"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro","tag":"3.13.13-latest"},"ingress":{"annotations":{},"enabled":true,"hosts":[{"host":"INGRESS.HOST.NAME","paths":[{"path":"/talk","pathType":"Prefix"}]}]},"livenessProbe":{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8000,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5},"overrideEnv":[{"name":"RASA_PRO_LICENSE","valueFrom":{"secretKeyRef":{"key":"RASA_PRO_LICENSE_SECRET_KEY","name":"studio-secrets"}}},{"name":"OPENAI_API_KEY","valueFrom":{"secretKeyRef":{"key":"OPENAI_API_KEY_SECRET_KEY","name":"studio-secrets"}}}],"persistence":{"create":true,"hostPath":{"enabled":false},"storageCapacity":"1Gi","storageClassName":null,"storageRequests":"1Gi"},"podSecurityContext":{"fsGroup":1001},"readinessProbe":{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8000,"scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5},"replicaCount":1,"resources":{},"service":{"port":80,"targetPort":8000},"settings":{"mountDefaultConfigmap":false,"mountModelsVolume":false,"useDefaultArgs":false},"strategy":{"type":"Recreate"}},"rasaProServices":{"enabled":false}}` |
| rasa.rasa.ingress.hosts[0] | object | Please update the below URL with the correct host name of the Studio deployment | `{"host":"INGRESS.HOST.NAME","paths":[{"path":"/talk","pathType":"Prefix"}]}` |
| rasa.rasa.persistence.storageClassName | string | Make sure to set the correct storage class name based on your cluster configuration | `nil` |
| rasa.rasa.podSecurityContext.fsGroup | int | User ID of the container to access the mounted volume | `1001` |
| rasa.rasa.resources | object | rasa.resources specifies the resources limits and requests | `{}` |
| replicated.enabled | bool |  | `false` |
| replicated.sdkVersion | string |  | `"1.8.1"` |
| repository | string | repository specifies image repository for Studio | `"europe-west3-docker.pkg.dev/rasa-releases/studio/"` |
| tag | string | tag specifies image tag for Studio # Overrides the image tag whose default is the chart appVersion. | `"1.15.1-latest"` |
| webClient.additionalContainers | list | webClient.additionalContainers defines additional containers to run alongside the main Web Client container. Example: - name: sidecar   image: busybox   command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30; done"] | `[]` |
| webClient.affinity | object | webClient.affinity defines affinity rules for the web client pods. | `{}` |
| webClient.annotations | object | webClient.annotations defines annotations to add to all Studio Web Client resources. These annotations will be merged with deploymentAnnotations (deploymentAnnotations take precedence if keys conflict). Example:   custom.annotation/key: value Ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ | `{}` |
| webClient.envFrom | list | webClient.envFrom defines additional environment variables from ConfigMap or Secret. Example: - configMapRef:     name: my-configmap - secretRef:     name: my-secret | `[]` |
| webClient.environmentVariables | object | webClient.environmentVariables defines the environment variables for the Web Client deployment. Example: Specify the string value for variables   value: my-value These environment variables are only being passed to the `configmap`, not to the container, therefore they cannot be a secret! | `{}` |
| webClient.image | object | webClient.image defines the container image settings for the web client service. | `{"name":"studio-web-client","pullPolicy":"IfNotPresent"}` |
| webClient.image.name | string | webClient.image.name is the name of the Web Client container image. | `"studio-web-client"` |
| webClient.image.pullPolicy | string | webClient.image.pullPolicy is the container image pull policy. | `"IfNotPresent"` |
| webClient.ingress | object | webClient.ingress defines how the web client service is exposed externally. | `{"additionalAnnotations":{},"className":"","enabled":true,"labels":{},"tls":[]}` |
| webClient.ingress.additionalAnnotations | object | webClient.ingress.additionalAnnotations defines additional annotations for the ingress resource. | `{}` |
| webClient.ingress.className | string | webClient.ingress.className is the ingress class name. | `""` |
| webClient.ingress.enabled | bool | webClient.ingress.enabled determines whether to create an ingress resource. | `true` |
| webClient.ingress.labels | object | webClient.ingress.labels defines labels to add to the ingress resource. | `{}` |
| webClient.ingress.tls | list | webClient.ingress.tls defines the TLS configuration for the ingress. | `[]` |
| webClient.livenessProbe | object | webClient.livenessProbe defines the liveness probe configuration. | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8080,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| webClient.livenessProbe.enabled | bool | webClient.livenessProbe.enabled determines whether to enable the liveness probe. | `true` |
| webClient.livenessProbe.failureThreshold | int | webClient.livenessProbe.failureThreshold is the number of failures before the container is considered unhealthy. | `6` |
| webClient.livenessProbe.httpGet | object | webClient.livenessProbe.httpGet defines the HTTP GET probe configuration. | `{"path":"/","port":8080,"scheme":"HTTP"}` |
| webClient.livenessProbe.httpGet.path | string | webClient.livenessProbe.httpGet.path is the path to check for liveness. | `"/"` |
| webClient.livenessProbe.httpGet.port | int | webClient.livenessProbe.httpGet.port is the port to check for liveness. | `8080` |
| webClient.livenessProbe.httpGet.scheme | string | webClient.livenessProbe.httpGet.scheme is the protocol to use for the check. | `"HTTP"` |
| webClient.livenessProbe.initialDelaySeconds | int | webClient.livenessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. | `15` |
| webClient.livenessProbe.periodSeconds | int | webClient.livenessProbe.periodSeconds is how often to perform the probe. | `15` |
| webClient.livenessProbe.successThreshold | int | webClient.livenessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. | `1` |
| webClient.livenessProbe.timeoutSeconds | int | webClient.livenessProbe.timeoutSeconds is the number of seconds after which the probe times out. | `5` |
| webClient.nodeSelector | object | webClient.nodeSelector defines which nodes the web client pods can run on. | `{}` |
| webClient.podAnnotations | object | webClient.podAnnotations defines annotations to add to the web client pod. Example:   container.apparmor.security.beta.kubernetes.io/studio-web-client: runtime/default | `{}` |
| webClient.podSecurityContext | object | webClient.podSecurityContext defines the security settings for the entire pod. | `{"enabled":true}` |
| webClient.podSecurityContext.enabled | bool | webClient.podSecurityContext.enabled determines whether to enable the pod security context. | `true` |
| webClient.readinessProbe | object | webClient.readinessProbe defines the readiness probe configuration. | `{"enabled":true,"failureThreshold":6,"httpGet":{"path":"/","port":8080,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` |
| webClient.readinessProbe.enabled | bool | webClient.readinessProbe.enabled determines whether to enable the readiness probe. | `true` |
| webClient.readinessProbe.failureThreshold | int | webClient.readinessProbe.failureThreshold is the number of failures before the container is considered not ready. | `6` |
| webClient.readinessProbe.httpGet | object | webClient.readinessProbe.httpGet defines the HTTP GET probe configuration. | `{"path":"/","port":8080,"scheme":"HTTP"}` |
| webClient.readinessProbe.httpGet.path | string | webClient.readinessProbe.httpGet.path is the path to check for readiness. | `"/"` |
| webClient.readinessProbe.httpGet.port | int | webClient.readinessProbe.httpGet.port is the port to check for readiness. | `8080` |
| webClient.readinessProbe.httpGet.scheme | string | webClient.readinessProbe.httpGet.scheme is the protocol to use for the check. | `"HTTP"` |
| webClient.readinessProbe.initialDelaySeconds | int | webClient.readinessProbe.initialDelaySeconds is the number of seconds to wait before starting probe. | `15` |
| webClient.readinessProbe.periodSeconds | int | webClient.readinessProbe.periodSeconds is how often to perform the probe. | `15` |
| webClient.readinessProbe.successThreshold | int | webClient.readinessProbe.successThreshold is the minimum consecutive successes for the probe to be considered successful. | `1` |
| webClient.readinessProbe.timeoutSeconds | int | webClient.readinessProbe.timeoutSeconds is the number of seconds after which the probe times out. | `5` |
| webClient.replicaCount | int | webClient.replicaCount is the number of replicas for the Web Client deployment. | `1` |
| webClient.resources | object | webClient.resources defines the resource limits and requests for the web client. | `{}` |
| webClient.securityContext | object | webClient.securityContext defines the security settings for the web client container. | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true}` |
| webClient.securityContext.allowPrivilegeEscalation | bool | webClient.securityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. | `false` |
| webClient.securityContext.capabilities | object | webClient.securityContext.capabilities defines the Linux capabilities configuration. | `{"drop":["ALL"]}` |
| webClient.securityContext.capabilities.drop | list | webClient.securityContext.capabilities.drop defines capabilities to drop from the container. | `["ALL"]` |
| webClient.securityContext.enabled | bool | webClient.securityContext.enabled determines whether to enable the security context. | `true` |
| webClient.securityContext.runAsNonRoot | bool | webClient.securityContext.runAsNonRoot determines whether to run the container as a non-root user. | `true` |
| webClient.service | object | webClient.service defines how the web client service is exposed within the cluster. | `{"port":80,"targetPort":8080,"type":"ClusterIP"}` |
| webClient.service.port | int | webClient.service.port is the port number for the service. | `80` |
| webClient.service.targetPort | int | webClient.service.targetPort is the target port in the container. | `8080` |
| webClient.service.type | string | webClient.service.type is the type of Kubernetes service. | `"ClusterIP"` |
| webClient.serviceAccount | object | webClient.serviceAccount defines the Kubernetes service account used by the web client pod. | `{"annotations":{},"create":false,"name":""}` |
| webClient.serviceAccount.annotations | object | webClient.serviceAccount.annotations defines annotations to add to the service account. | `{}` |
| webClient.serviceAccount.create | bool | webClient.serviceAccount.create determines whether to create a new service account. | `false` |
| webClient.serviceAccount.name | string | webClient.serviceAccount.name is the name of the service account to use. | `""` |
| webClient.tolerations | list | webClient.tolerations defines tolerations for the web client pods. | `[]` |
