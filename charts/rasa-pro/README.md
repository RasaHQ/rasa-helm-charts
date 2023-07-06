# rasa-pro

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Rasa Pro Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dnsConfig | object | `{}` | Specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | Specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| duckling.external.enabled | bool | `false` | Determine if external URL is used |
| duckling.external.url | string | `""` | External URL to Duckling |
| duckling.install | bool | `false` | Install Duckling |
| fullnameOverride | string | `""` | Override the full qualified app name |
| global.additionalDeploymentLabels | object | `{}` | additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| hostNetwork | bool | `false` | Controls whether the pod may use the node network namespace |
| imagePullSecrets | list | `[]` | Repository pull secrets |
| nameOverride | string | `""` | Override name of app |
| networkPolicy.denyAll | bool | `false` | Specifies whether to apply denyAll network policy |
| networkPolicy.enabled | bool | `false` | Specifies whether to enable network policies |
| networkPolicy.nodeCIDR | list | `[]` | Allow for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes |
| rasa-action-server.external.enabled | bool | `false` | Determine if external URL is used |
| rasa-action-server.external.url | string | `""` | External URL to Rasa Action Server |
| rasa-action-server.install | bool | `false` | Install Rasa Action Server |
| rasaPro.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| rasaPro.args | list | `[]` |  |
| rasaPro.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Specifies the HPA settings |
| rasaPro.autoscaling.enabled | bool | `false` | Specifies whether autoscaling should be enabled |
| rasaPro.autoscaling.maxReplicas | int | `100` | Specifies the maximum number of replicas |
| rasaPro.autoscaling.minReplicas | int | `1` | Specifies the minimum number of replicas |
| rasaPro.autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the target CPU/Memory utilization percentage |
| rasaPro.command | list | `[]` |  |
| rasaPro.extraArgs | list | `[]` |  |
| rasaPro.extraContainers | list | `[]` |  |
| rasaPro.extraEnv | list | `[]` |  |
| rasaPro.image | object | `{"pullPolicy":"IfNotPresent","repository":"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro","tag":""}` | Define image settings |
| rasaPro.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| rasaPro.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` | Specifies image repository |
| rasaPro.image.tag | string | `""` | Specifies image tag Overrides the image tag whose default is the chart appVersion. |
| rasaPro.ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}],"labels":{},"tls":[]}` | Configure the ingress resource that allows you to access the deployment installation. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| rasaPro.ingress.annotations | object | `{}` | Annotations to add to the ingress |
| rasaPro.ingress.className | string | `""` | Specifies the ingress className to be used |
| rasaPro.ingress.enabled | bool | `false` | Specifies whether an ingress service should be created |
| rasaPro.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}]` | Specifies the hosts for this ingress |
| rasaPro.ingress.labels | object | `{}` | Labels to add to the ingress |
| rasaPro.ingress.tls | list | `[]` | Spefices the TLS configuration for ingress |
| rasaPro.initContainers | list | `[]` |  |
| rasaPro.livenessProbe | object | `{"enabled":false,"failureThreshold":6,"httpGet":{"path":"/","port":80,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| rasaPro.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| rasaPro.podAnnotations | object | `{}` | Annotations to add to the pod |
| rasaPro.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| rasaPro.readinessProbe | object | `{"enabled":false,"failureThreshold":6,"httpGet":{"path":"/","port":80,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| rasaPro.replicaCount | int | `1` | Specifies number of replicas |
| rasaPro.resources | object | `{}` | Specifies the resources limits and requests |
| rasaPro.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| rasaPro.service | object | `{"port":80,"targetPort":80,"type":"ClusterIP"}` | Define service |
| rasaPro.service.port | int | `80` | Specify service port |
| rasaPro.service.targetPort | int | `80` | Specify service target port |
| rasaPro.service.type | string | `"ClusterIP"` | Specify service type |
| rasaPro.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Define service account |
| rasaPro.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| rasaPro.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| rasaPro.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| rasaPro.settings.cors | string | `"*"` |  |
| rasaPro.settings.credentials.additionalChannelCredentials | object | `{}` |  |
| rasaPro.settings.credentials.enabled | bool | `true` |  |
| rasaPro.settings.debugMode | bool | `false` |  |
| rasaPro.settings.enableAPI | bool | `true` |  |
| rasaPro.settings.endpoints.action.endpointURL | string | `"/webhook"` |  |
| rasaPro.settings.endpoints.additionalEndpoints | object | `{}` |  |
| rasaPro.settings.endpoints.eventBroker.enabled | bool | `false` |  |
| rasaPro.settings.endpoints.eventBroker.password | string | `"${RABBITMQ_PASSWORD}"` |  |
| rasaPro.settings.endpoints.eventBroker.port | string | `"${RABBITMQ_PORT}"` |  |
| rasaPro.settings.endpoints.eventBroker.queues[0] | string | `"rasa_production_events"` |  |
| rasaPro.settings.endpoints.eventBroker.type | string | `"pika"` |  |
| rasaPro.settings.endpoints.eventBroker.url | string | `"${RABBITMQ_HOST}"` |  |
| rasaPro.settings.endpoints.eventBroker.username | string | `"${RABBITMQ_USERNAME}"` |  |
| rasaPro.settings.endpoints.lockStore.db | string | `"1"` |  |
| rasaPro.settings.endpoints.lockStore.enabled | bool | `false` |  |
| rasaPro.settings.endpoints.lockStore.password | string | `"${REDIS_PASSWORD}"` |  |
| rasaPro.settings.endpoints.lockStore.port | string | `"${REDIS_PORT}"` |  |
| rasaPro.settings.endpoints.lockStore.type | string | `"redis"` |  |
| rasaPro.settings.endpoints.lockStore.url | string | `"${REDIS_HOST}"` |  |
| rasaPro.settings.endpoints.models.enabled | bool | `false` |  |
| rasaPro.settings.endpoints.models.token | string | `"token"` |  |
| rasaPro.settings.endpoints.models.url | string | `""` |  |
| rasaPro.settings.endpoints.models.useRasaXasModelServer.enabled | bool | `false` |  |
| rasaPro.settings.endpoints.models.useRasaXasModelServer.tag | string | `"production"` |  |
| rasaPro.settings.endpoints.models.waitTimeBetweenPulls | int | `20` |  |
| rasaPro.settings.endpoints.trackerStore.db | string | `"${DB_DATABASE}"` |  |
| rasaPro.settings.endpoints.trackerStore.dialect | string | `"postgresql"` |  |
| rasaPro.settings.endpoints.trackerStore.enabled | bool | `true` |  |
| rasaPro.settings.endpoints.trackerStore.login_db | string | `"${DB_DATABASE}"` |  |
| rasaPro.settings.endpoints.trackerStore.password | string | `"${DB_PASSWORD}"` |  |
| rasaPro.settings.endpoints.trackerStore.type | string | `"sql"` |  |
| rasaPro.settings.endpoints.trackerStore.url | string | `"${DB_HOST}"` |  |
| rasaPro.settings.endpoints.trackerStore.username | string | `"${DB_USER}"` |  |
| rasaPro.settings.initialModel | string | `""` |  |
| rasaPro.settings.rasaX.enabled | bool | `false` |  |
| rasaPro.settings.rasaX.token | string | `"rasaXToken"` |  |
| rasaPro.settings.rasaX.url | string | `""` |  |
| rasaPro.settings.rasaX.useConfigEndpoint | bool | `false` |  |
| rasaPro.settings.telemetry.enabled | bool | `true` |  |
| rasaPro.settings.token | string | `""` |  |
| rasaPro.settings.trainInitialModel | bool | `false` |  |
| rasaPro.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| rasaPro.volumeMounts | list | `[]` |  |
| rasaPro.volumes | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
