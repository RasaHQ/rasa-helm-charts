# rasa

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Rasa Pro Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| actionServer.external.enabled | bool | `false` | Determine if external URL is used |
| actionServer.external.url | string | `""` | External URL to Rasa Action Server |
| actionServer.install | bool | `false` | Install Rasa Action Server |
| deploymentAnnotations | object | `{}` | Annotations to add to the rasa-oss deployment |
| deploymentLabels | object | `{}` | Labels to add to the rasa-oss deployment |
| dnsConfig | object | `{}` | Specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | Specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| duckling.external.enabled | bool | `false` | Determine if external URL is used |
| duckling.external.url | string | `""` | External URL to Duckling |
| duckling.install | bool | `false` | Install Duckling |
| fullnameOverride | string | `""` | Override the full qualified app name |
| global.additionalDeploymentLabels | object | `{}` | additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| hostNetwork | bool | `false` | Controls whether the pod may use the node network namespace |
| imagePullSecrets | list | `[]` | Repository pull secrets |
| internal | bool | `false` |  |
| nameOverride | string | `""` | Override name of app |
| networkPolicy.denyAll | bool | `false` | Specifies whether to apply denyAll network policy |
| networkPolicy.enabled | bool | `false` | Specifies whether to enable network policies |
| networkPolicy.nodeCIDR | list | `[]` | Allow for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes |
| podLabels | object | `{}` | Labels to add to the rasa-oss's pod(s) |
| rasa.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| rasa.args | list | `[]` | Override the default arguments for the container |
| rasa.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Specifies the HPA settings |
| rasa.autoscaling.enabled | bool | `false` | Specifies whether autoscaling should be enabled |
| rasa.autoscaling.maxReplicas | int | `100` | Specifies the maximum number of replicas |
| rasa.autoscaling.minReplicas | int | `1` | Specifies the minimum number of replicas |
| rasa.autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the target CPU/Memory utilization percentage |
| rasa.command | list | `[]` | Override the default command for the container |
| rasa.enabled | bool | `true` |  |
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
| rasa.plus.enabled | bool | `true` |  |
| rasa.plus.settings.additionalSettings | object | `{}` |  |
| rasa.plus.settings.cache.directory | string | `nil` |  |
| rasa.plus.settings.cache.maxSize | int | `1000` |  |
| rasa.plus.settings.cache.name | string | `"cache.db"` |  |
| rasa.plus.settings.ducklingHttpUrl | string | `nil` |  |
| rasa.plus.settings.lockStore.ticketLockLifetime | int | `60` |  |
| rasa.plus.settings.logging.forceJsonLogging | string | `nil` |  |
| rasa.plus.settings.logging.logLevel | string | `"info"` |  |
| rasa.plus.settings.logging.logLevelFaker | string | `"error"` |  |
| rasa.plus.settings.logging.logLevelKafka | string | `"error"` |  |
| rasa.plus.settings.logging.logLevelLibraries | string | `"error"` |  |
| rasa.plus.settings.logging.logLevelPresidio | string | `"error"` |  |
| rasa.plus.settings.logging.logLevelRabbitMq | string | `"error"` |  |
| rasa.plus.settings.maxNumberOfPreditions | int | `10` |  |
| rasa.plus.settings.modelStorage.aws.accessKeyId.secretKey | string | `nil` |  |
| rasa.plus.settings.modelStorage.aws.accessKeyId.secretName | string | `nil` |  |
| rasa.plus.settings.modelStorage.aws.bucketName | string | `nil` |  |
| rasa.plus.settings.modelStorage.aws.defaultRegion | string | `nil` |  |
| rasa.plus.settings.modelStorage.aws.endpointUrl | string | `nil` |  |
| rasa.plus.settings.modelStorage.aws.secretAccessKey.secretKey | string | `nil` |  |
| rasa.plus.settings.modelStorage.aws.secretAccessKey.secretName | string | `nil` |  |
| rasa.plus.settings.modelStorage.azure.accountKey.secretKey | string | `nil` |  |
| rasa.plus.settings.modelStorage.azure.accountKey.secretName | string | `nil` |  |
| rasa.plus.settings.modelStorage.azure.accountName | string | `nil` |  |
| rasa.plus.settings.modelStorage.azure.container | string | `nil` |  |
| rasa.plus.settings.modelStorage.gcp.applicationCredentials.secretKey | string | `nil` |  |
| rasa.plus.settings.modelStorage.gcp.applicationCredentials.secretName | string | `nil` |  |
| rasa.plus.settings.postgresTrackerStore.maxOverflow | int | `100` |  |
| rasa.plus.settings.postgresTrackerStore.poolSize | int | `50` |  |
| rasa.plus.settings.postgresTrackerStore.schema | string | `nil` |  |
| rasa.plus.settings.rabbitmq.sslCAFile.secretKey | string | `nil` |  |
| rasa.plus.settings.rabbitmq.sslCAFile.secretName | string | `nil` |  |
| rasa.plus.settings.rabbitmq.sslClientCertificate.secretKey | string | `nil` |  |
| rasa.plus.settings.rabbitmq.sslClientCertificate.secretName | string | `nil` |  |
| rasa.plus.settings.rabbitmq.sslClientKey.secretKey | string | `nil` |  |
| rasa.plus.settings.rabbitmq.sslClientKey.secretName | string | `nil` |  |
| rasa.plus.settings.rabbitmq.sslKeyPassword.secretKey | string | `nil` |  |
| rasa.plus.settings.rabbitmq.sslKeyPassword.secretName | string | `nil` |  |
| rasa.plus.settings.rasaEnvironment | string | `"production"` |  |
| rasa.plus.settings.rasaProLicence.secretKey | string | `nil` |  |
| rasa.plus.settings.rasaProLicence.secretName | string | `nil` |  |
| rasa.plus.settings.sanicServer.backlog | int | `100` |  |
| rasa.plus.settings.sanicServer.workers | int | `1` |  |
| rasa.plus.settings.secretsManager.enabled | bool | `true` |  |
| rasa.plus.settings.secretsManager.secretManager | string | `"vault"` |  |
| rasa.plus.settings.secretsManager.vaultHost | string | `nil` |  |
| rasa.plus.settings.secretsManager.vaultRasaSecretsPath | string | `"rasa-secrets"` |  |
| rasa.plus.settings.secretsManager.vaultToken.secretKey | string | `nil` |  |
| rasa.plus.settings.secretsManager.vaultToken.secretName | string | `nil` |  |
| rasa.plus.settings.secretsManager.vaultTransitMountPoint | string | `nil` |  |
| rasa.plus.settings.shellStreamReadingTimeoutInSeconds | int | `10` |  |
| rasa.plus.settings.telemetry.debug | bool | `false` |  |
| rasa.plus.settings.telemetry.enabled | bool | `false` |  |
| rasa.plus.settings.tensorflow.deterministicOps | bool | `false` |  |
| rasa.plus.settings.tensorflow.gpuMemoryAlloc | string | `nil` |  |
| rasa.plus.settings.tensorflow.interOpParallelismThreads | string | `nil` |  |
| rasa.plus.settings.tensorflow.intraOpParallelismThreads | string | `nil` |  |
| rasa.plus.settings.tracing.serviceName | string | `"rasa"` |  |
| rasa.plus.volumes.models | string | `nil` |  |
| rasa.plus.volumes.ssl | string | `nil` |  |
| rasa.podAnnotations | object | `{}` | Annotations to add to the pod |
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
| rasa.settings | object | `{"cors":"*","credentials":{"additionalChannelCredentials":{},"enabled":true},"debugMode":false,"enableAPI":true,"endpoints":{"actionEndpoint":{"url":"/webhook"},"additionalEndpoints":{},"eventBroker":{"enabled":true,"type":""},"lockStore":{"db":"1","enabled":true,"keyPrefix":"","password":"","port":"","socketTimeout":"","url":"","useSsl":false},"models":{"enabled":true,"token":{"enabled":true,"secretKey":"","secretName":""},"url":"","waitTimeBetweenPulls":20},"trackerStore":{"enabled":true,"type":"dynamo"}},"initialModel":"","jwtMethod":"HS256","jwtSecret":{"secretKey":"","secretName":""},"port":5005,"scheme":"http","telemetry":{"debug":false,"enabled":true},"token":{"secretKey":"","secretName":""},"trainInitialModel":false}` | Allow the deployment to perform a rolling update # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy strategy:   type: RollingUpdate   rollingUpdate:     maxSurge: 1     maxUnavailable: 0 |
| rasa.settings.cors | string | `"*"` | CORS for the passed origin. Default is * to allow all origins |
| rasa.settings.credentials.additionalChannelCredentials | object | `{}` | Additional channel credentials which should be used by Rasa to connect to various input channels # See: https://rasa.com/docs/rasa/messaging-and-voice-channels |
| rasa.settings.credentials.enabled | bool | `true` | Enable credentials configuration for channel connectors |
| rasa.settings.debugMode | bool | `false` | Enable debug mode |
| rasa.settings.enableAPI | bool | `true` | Start the web server API in addition to the input channel |
| rasa.settings.initialModel | string | `""` | Initial model to download and load if a model server or remote storage is not used. It has to be a URL (without auth) that points to a tar.gz file |
| rasa.settings.jwtSecret | object | `{"secretKey":"","secretName":""}` | JWT Token |
| rasa.settings.port | int | `5005` | Port on which Rasa runs |
| rasa.settings.scheme | string | `"http"` | Scheme by which the service are accessible |
| rasa.settings.telemetry.enabled | bool | `true` | Enable telemetry See: https://rasa.com/docs/rasa/telemetry/telemetry/ |
| rasa.settings.token | object | `{"secretKey":"","secretName":""}` | Token Rasa accepts as authentication token from other Rasa services |
| rasa.settings.trainInitialModel | bool | `false` | Train a model if an initial model is not defined. This parameter is ignored if the `applicationSettings.initialModel` is defined |
| rasa.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| rasa.volumeMounts | list | `[]` | Specify additional volumes to mount in the rasa-oss container |
| rasa.volumes | list | `[]` | Specify additional volumes to mount in the rasa-oss container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| rasaProServices | object | `{"affinity":{},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"enabled":true,"environmentVariables":{"KAFKA_BROKER_ADDRESS":{"value":""},"KAFKA_SASL_MECHANISM":{"value":"PLAIN"},"KAFKA_SASL_PASSWORD":{"secret":{"key":null,"name":null}},"KAFKA_SASL_USERNAME":{"value":""},"KAFKA_SECURITY_PROTOCOL":{"value":"PLAINTEXT"},"KAFKA_SSL_CA_LOCATION":{"value":""},"KAFKA_TOPIC":{"value":"rasa_core_events"},"LOGGING_LEVEL":{"value":"INFO"},"RASA_ANALYTICS_DB_URL":{"value":""},"RASA_PRO_LICENSE":{"secret":{"key":null,"name":null}}},"image":{"pullPolicy":"IfNotPresent","repository":"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro","tag":""},"livenessProbe":{"enabled":false,"failureThreshold":6,"httpGet":{"path":"/healthcheck","port":8732,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5},"nodeSelector":{},"podAnnotations":{},"podSecurityContext":{"enabled":true},"readinessProbe":{"enabled":false,"failureThreshold":6,"httpGet":{"path":"/healthcheck","port":8732,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5},"replicaCount":1,"resources":{},"securityContext":{"enabled":true},"service":{"annotations":{},"port":8732,"targetPort":8732,"type":"ClusterIP"},"serviceAccount":{"annotations":{},"create":false,"name":""},"strategy":{"type":"RollingUpdate"},"tolerations":[]}` | Settings for Rasa Pro Services |
| rasaProServices.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| rasaProServices.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Specifies the HPA settings |
| rasaProServices.autoscaling.enabled | bool | `false` | Specifies whether autoscaling should be enabled |
| rasaProServices.autoscaling.maxReplicas | int | `100` | Specifies the maximum number of replicas |
| rasaProServices.autoscaling.minReplicas | int | `1` | Specifies the minimum number of replicas |
| rasaProServices.autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the target CPU/Memory utilization percentage |
| rasaProServices.enabled | bool | `true` | Enable Rasa Pro Services deployment |
| rasaProServices.image | object | `{"pullPolicy":"IfNotPresent","repository":"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro","tag":""}` | Define image settings |
| rasaProServices.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| rasaProServices.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` | Specifies image repository |
| rasaProServices.image.tag | string | `""` | Specifies image tag Overrides the image tag whose default is the chart appVersion. |
| rasaProServices.livenessProbe | object | `{"enabled":false,"failureThreshold":6,"httpGet":{"path":"/healthcheck","port":8732,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| rasaProServices.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| rasaProServices.podAnnotations | object | `{}` | Annotations to add to the pod |
| rasaProServices.podSecurityContext | object | `{"enabled":true}` | Define pod security context |
| rasaProServices.readinessProbe | object | `{"enabled":false,"failureThreshold":6,"httpGet":{"path":"/healthcheck","port":8732,"scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| rasaProServices.replicaCount | int | `1` | Specifies number of replicas |
| rasaProServices.resources | object | `{}` | Specifies the resources limits and requests |
| rasaProServices.securityContext | object | `{"enabled":true}` | Define security context that allows you to overwrite the pod-level security context |
| rasaProServices.service | object | `{"annotations":{},"port":8732,"targetPort":8732,"type":"ClusterIP"}` | Define service |
| rasaProServices.service.annotations | object | `{}` | Annotations to add to the service |
| rasaProServices.service.port | int | `8732` | Specify service port |
| rasaProServices.service.targetPort | int | `8732` | Specify service target port |
| rasaProServices.service.type | string | `"ClusterIP"` | Specify service type |
| rasaProServices.serviceAccount | object | `{"annotations":{},"create":false,"name":""}` | Define service account |
| rasaProServices.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| rasaProServices.serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| rasaProServices.serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| rasaProServices.strategy | object | `{"type":"RollingUpdate"}` | Allow the deployment to perform a rolling update # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| rasaProServices.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
