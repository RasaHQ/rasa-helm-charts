# rasa

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Rasa Pro Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dnsConfig | object | `{}` | Specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | Specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| duckling | string | `nil` | Settings for Duckling |
| fullnameOverride | string | `""` | Override the full qualified app name |
| global.additionalDeploymentLabels | object | `{}` | additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| hostNetwork | bool | `false` | Controls whether the pod may use the node network namespace |
| imagePullSecrets | list | `[]` | Repository pull secrets |
| nameOverride | string | `""` | Override name of app |
| networkPolicy.denyAll | bool | `false` | Specifies whether to apply denyAll network policy |
| networkPolicy.enabled | bool | `false` | Specifies whether to enable network policies |
| networkPolicy.nodeCIDR | list | `[]` | Allow for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes |
| rasa-pro-services | string | `nil` | Settings for Rasa Pro Services |
| rasa.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| rasa.args | list | `[]` | Override the default arguments for the container |
| rasa.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Specifies the HPA settings |
| rasa.autoscaling.enabled | bool | `false` | Specifies whether autoscaling should be enabled |
| rasa.autoscaling.maxReplicas | int | `100` | Specifies the maximum number of replicas |
| rasa.autoscaling.minReplicas | int | `1` | Specifies the minimum number of replicas |
| rasa.autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the target CPU/Memory utilization percentage |
| rasa.command | list | `[]` | Override the default command for the container |
| rasa.deploymentAnnotations | object | `{}` | Annotations to add to the rasa-oss deployment |
| rasa.deploymentLabels | object | `{}` | Labels to add to the rasa-oss deployment |
| rasa.extraArgs | list | `[]` | Add additional arguments to the default one |
| rasa.extraContainers | list | `[]` | Allow to specify additional containers for the Rasa Open Source Deployment |
| rasa.extraEnv | list | `[]` | Add extra environment variables |
| rasa.image | object | `{"pullPolicy":"IfNotPresent","repository":"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro","tag":""}` | Define image settings |
| rasa.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| rasa.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` | Specifies image repository |
| rasa.image.tag | string | `""` | Specifies image tag Overrides the image tag whose default is the chart appVersion. |
| rasa.ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}],"labels":{},"tls":[]}` | Configure the ingress resource that allows you to access the deployment installation. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| rasa.ingress.annotations | object | `{}` | Annotations to add to the ingress |
| rasa.ingress.className | string | `""` | Specifies the ingress className to be used |
| rasa.ingress.enabled | bool | `false` | Specifies whether an ingress service should be created |
| rasa.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}]` | Specifies the hosts for this ingress |
| rasa.ingress.labels | object | `{}` | Labels to add to the ingress |
| rasa.ingress.tls | list | `[]` | Spefices the TLS configuration for ingress |
| rasa.initContainers | list | `[]` | Allow to specify init containers for the Rasa Open Source Deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ |
| rasa.livenessProbe | object | `{"enabled":false,"failureThreshold":6,"httpGet":{"path":"/","port":80,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| rasa.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| rasa.podAnnotations | object | `{}` | Annotations to add to the pod |
| rasa.podLabels | object | `{}` | Labels to add to the rasa-oss's pod(s) |
| rasa.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| rasa.readinessProbe | object | `{"enabled":false,"failureThreshold":6,"httpGet":{"path":"/","port":80,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| rasa.replicaCount | int | `1` | Specifies number of replicas |
| rasa.resources | object | `{}` | Specifies the resources limits and requests |
| rasa.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| rasa.service | object | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":5005,"targetPort":5005,"type":"ClusterIP"}` | Define service |
| rasa.service.annotations | object | `{}` | Annotations to add to the service |
| rasa.service.externalTrafficPolicy | string | `"Cluster"` | Enable client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip |
| rasa.service.loadBalancerIP | string | `nil` | Exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer |
| rasa.service.nodePort | string | `nil` | Specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport |
| rasa.service.port | int | `5005` | Specify service port |
| rasa.service.targetPort | int | `5005` | Specify service target port |
| rasa.service.type | string | `"ClusterIP"` | Specify service type |
| rasa.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Define service account |
| rasa.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| rasa.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| rasa.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| rasa.settings.cors | string | `"*"` | CORS for the passed origin. Default is * to allow all origins |
| rasa.settings.credentials.additionalChannelCredentials | object | `{}` | Additional channel credentials which should be used by Rasa to connect to various input channels # See: https://rasa.com/docs/rasa/messaging-and-voice-channels |
| rasa.settings.credentials.enabled | bool | `true` | Enable credentials configuration for channel connectors |
| rasa.settings.debugMode | bool | `false` | Enable debug mode |
| rasa.settings.enableAPI | bool | `true` | Start the web server API in addition to the input channel |
| rasa.settings.endpoints.action.endpointURL | string | `"/webhook"` |  |
| rasa.settings.endpoints.additionalEndpoints | object | `{}` |  |
| rasa.settings.endpoints.eventBroker.enabled | bool | `false` |  |
| rasa.settings.endpoints.eventBroker.password | string | `""` |  |
| rasa.settings.endpoints.eventBroker.port | string | `""` |  |
| rasa.settings.endpoints.eventBroker.queues[0] | string | `"rasa_production_events"` |  |
| rasa.settings.endpoints.eventBroker.type | string | `"pika"` |  |
| rasa.settings.endpoints.eventBroker.url | string | `""` |  |
| rasa.settings.endpoints.eventBroker.username | string | `""` |  |
| rasa.settings.endpoints.lockStore.db | string | `"1"` |  |
| rasa.settings.endpoints.lockStore.enabled | bool | `false` |  |
| rasa.settings.endpoints.lockStore.password | string | `""` |  |
| rasa.settings.endpoints.lockStore.port | string | `""` |  |
| rasa.settings.endpoints.lockStore.type | string | `"redis"` |  |
| rasa.settings.endpoints.lockStore.url | string | `""` |  |
| rasa.settings.endpoints.models.enabled | bool | `false` |  |
| rasa.settings.endpoints.models.token | string | `"token"` |  |
| rasa.settings.endpoints.models.url | string | `""` |  |
| rasa.settings.endpoints.models.useRasaXasModelServer.enabled | bool | `false` |  |
| rasa.settings.endpoints.models.useRasaXasModelServer.tag | string | `"production"` |  |
| rasa.settings.endpoints.models.waitTimeBetweenPulls | int | `20` |  |
| rasa.settings.endpoints.trackerStore.db | string | `""` |  |
| rasa.settings.endpoints.trackerStore.dialect | string | `"postgresql"` |  |
| rasa.settings.endpoints.trackerStore.enabled | bool | `true` |  |
| rasa.settings.endpoints.trackerStore.login_db | string | `""` |  |
| rasa.settings.endpoints.trackerStore.password | string | `""` |  |
| rasa.settings.endpoints.trackerStore.type | string | `"sql"` |  |
| rasa.settings.endpoints.trackerStore.url | string | `""` |  |
| rasa.settings.endpoints.trackerStore.username | string | `""` |  |
| rasa.settings.initialModel | string | `""` | Initial model to download and load if a model server or remote storage is not used. It has to be a URL (without auth) that points to a tar.gz file |
| rasa.settings.port | int | `5005` | Port on which Rasa runs |
| rasa.settings.rasaX.enabled | bool | `false` | Run Rasa X / Enterprise server |
| rasa.settings.rasaX.token | string | `"rasaXToken"` | Token Rasa X / Enterprise accepts as authentication token from other Rasa services |
| rasa.settings.rasaX.url | string | `""` | URL to Rasa X / Enterprise, e.g. http://rasa-x.mydomain.com:5002 |
| rasa.settings.rasaX.useConfigEndpoint | bool | `false` | Rasa X / Enterprise endpoint URL from which to pull the runtime config |
| rasa.settings.scheme | string | `"http"` | Scheme by which the service are accessible |
| rasa.settings.telemetry.enabled | bool | `true` | Enable telemetry See: https://rasa.com/docs/rasa/telemetry/telemetry/ |
| rasa.settings.token | string | `"rasaToken"` | Token Rasa accepts as authentication token from other Rasa services |
| rasa.settings.trainInitialModel | bool | `false` | Train a model if an initial model is not defined. This parameter is ignored if the `applicationSettings.initialModel` is defined |
| rasa.strategy | object | `{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0},"type":"RollingUpdate"}` | Allow the deployment to perform a rolling update # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| rasa.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| rasa.volumeMounts | list | `[]` | Specify additional volumes to mount in the rasa-oss container |
| rasa.volumes | list | `[]` | Specify additional volumes to mount in the rasa-oss container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
