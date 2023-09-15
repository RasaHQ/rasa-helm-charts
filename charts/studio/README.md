# studio

This chart bootstraps Studio deployment on a Kubernetes cluster using the Helm package manager.

![Version: 0.1.32](https://img.shields.io/badge/Version-0.1.32-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 0.1.32
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
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/studio --version 0.1.32
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
| backend.migration | object | `{"enable":true,"image":{"name":"studio-database-migration"}}` | Define Studio Database Migration job settings |
| backend.migration.enable | bool | `true` | Specifies whether a database migration job should be created |
| backend.migration.image | object | `{"name":"studio-database-migration"}` | Specifies which image database migration job should use |
| backend.migration.image.name | string | `"studio-database-migration"` | Specifies the repository of the image |
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
| nameOverride | string | `""` | Override name of app |
| networkPolicy.denyAll | bool | `false` | Specifies whether to apply denyAll network policy |
| networkPolicy.enabled | bool | `false` | Specifies whether to enable network policies |
| networkPolicy.nodeCIDR | list | `[]` | Allow for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes |
| podLabels | object | `{}` | podLabels defines labels to add to all Studio pod(s) |
| repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/studio/"` | Specifies image repository |
| tag | string | `"0.1.3"` | Specifies image tag # Overrides the image tag whose default is the chart appVersion. |
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
