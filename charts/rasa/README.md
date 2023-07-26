# rasa

A Rasa Pro Helm chart for Kubernetes

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://registry-1.docker.io/helm-charts/rasa --version 0.1.0
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
$ helm pull oci://registry-1.docker.io/helm-charts/rasa --version 0.1.0
```

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
| rasa.plus.settings.cache | object | `{"directory":null,"maxSize":1000,"name":"cache.db"}` | cache for `rasa train` command |
| rasa.plus.settings.cache.directory | string | `nil` | default is equivalent of Path(".rasa", "cache") |
| rasa.plus.settings.cache.maxSize | int | `1000` | maximum size for the cache |
| rasa.plus.settings.cache.name | string | `"cache.db"` | name of the cache file |
| rasa.plus.settings.ducklingHttpUrl | string | `nil` | HTTP URL to the duckling service |
| rasa.plus.settings.lockStore | object | `{"ticketLockLifetime":60}` | Synchronization mechanism used by Rasa |
| rasa.plus.settings.lockStore.ticketLockLifetime | int | `60` | Lifetime of the ticket associated with a lock |
| rasa.plus.settings.logging | object | `{"forceJsonLogging":false,"logLevel":"info","logLevelFaker":"error","logLevelKafka":"error","logLevelLibraries":"error","logLevelMatplotlib":"error","logLevelPresidio":"error","logLevelRabbitMq":"error"}` | Set log levels for Rasa and external libraries See: https://rasa.com/docs/rasa/next/command-line-interface/#log-level |
| rasa.plus.settings.logging.forceJsonLogging | bool | `false` | Force logging in JSON |
| rasa.plus.settings.logging.logLevel | string | `"info"` | Rasa Log Level |
| rasa.plus.settings.logging.logLevelFaker | string | `"error"` | Configure log level for Faker |
| rasa.plus.settings.logging.logLevelKafka | string | `"error"` | Configrue log level for Kafka |
| rasa.plus.settings.logging.logLevelLibraries | string | `"error"` | Configure log level for Tensorflow, asyncio, APScheduler, SocketIO, Matplotlib, RabbitMQ, Kafka |
| rasa.plus.settings.logging.logLevelMatplotlib | string | `"error"` | Configure log level for Matplotlib |
| rasa.plus.settings.logging.logLevelPresidio | string | `"error"` | Configure log level for Presidio |
| rasa.plus.settings.logging.logLevelRabbitMq | string | `"error"` | Configure log level for RabbitMQ |
| rasa.plus.settings.maxNumberOfPreditions | int | `10` |  |
| rasa.plus.settings.postgresTrackerStore | object | `{"maxOverflow":100,"poolSize":50,"schema":"public"}` | Settings to customize connections to Postgres |
| rasa.plus.settings.postgresTrackerStore.maxOverflow | int | `100` | Maximum overflow size of the pool |
| rasa.plus.settings.postgresTrackerStore.poolSize | int | `50` | Pool Size configuration |
| rasa.plus.settings.postgresTrackerStore.schema | string | `"public"` | PostgreSQL schema to access |
| rasa.plus.settings.rabbitmq | object | `{"sslClientCertificate":{"secretKey":null,"secretName":null},"sslClientKey":{"secretKey":null,"secretName":null}}` | Settings to setup RabbitMQ SSL |
| rasa.plus.settings.rabbitmq.sslClientCertificate | object | `{"secretKey":null,"secretName":null}` | path to the SSL client certificate |
| rasa.plus.settings.rabbitmq.sslClientKey | object | `{"secretKey":null,"secretName":null}` | path to the SSL client key |
| rasa.plus.settings.rasaEnvironment | string | `"development"` | Environment: development or production |
| rasa.plus.settings.rasaProLicence | object | `{"secretKey":null,"secretName":null}` | Rasa Pro License See: https://rasa.com/connect-with-rasa/ |
| rasa.plus.settings.sanicServer.backlog | int | `100` | Number of unaccepted connections the server allows before refusing new connections |
| rasa.plus.settings.sanicServer.workers | int | `1` | Number of Sanic worker processes in the HTTP Server and Input Channel Server |
| rasa.plus.settings.secretsManager | object | `{"enabled":false,"secretManager":"vault","vaultHost":null,"vaultRasaSecretsPath":"rasa-secrets","vaultToken":{"secretKey":null,"secretName":null},"vaultTransitMountPoint":null}` | Store your assistant's secrets in an external credentials manager See: https://rasa.com/docs/rasa/secrets-managers/ TODO: Define if this should be part of values or it should be passed through `additionalSettings` |
| rasa.plus.settings.secretsManager.enabled | bool | `false` | Enabled if a Secret Manager is used |
| rasa.plus.settings.secretsManager.secretManager | string | `"vault"` | Secrets manager to use. Currently only "vault" is supported |
| rasa.plus.settings.secretsManager.vaultHost | string | `nil` | Address of the vault server |
| rasa.plus.settings.secretsManager.vaultRasaSecretsPath | string | `"rasa-secrets"` | Path to the secrets in the vault server |
| rasa.plus.settings.secretsManager.vaultToken | object | `{"secretKey":null,"secretName":null}` | Token to authenticate to the vault server |
| rasa.plus.settings.secretsManager.vaultTransitMountPoint | string | `nil` | If transit secrets engine is enabled set this to mount point of the transit engine |
| rasa.plus.settings.shellStreamReadingTimeoutInSeconds | int | `10` |  |
| rasa.plus.settings.telemetry.debug | bool | `false` | Print telemetry data to stdout |
| rasa.plus.settings.telemetry.enabled | bool | `true` | Allow Rasa to collect anonymous usage details |
| rasa.plus.settings.tensorflow | object | `{"deterministicOps":false,"gpuMemoryAlloc":null,"interOpParallelismThreads":null,"intraOpParallelismThreads":null}` | Tensorflow parameters |
| rasa.plus.settings.tracing.serviceName | string | `"rasa"` |  |
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
| rasa.settings.cors | string | `"*"` | CORS for the passed origin. Default is * to allow all origins |
| rasa.settings.credentials.additionalChannelCredentials | object | `{}` | Additional channel credentials which should be used by Rasa to connect to various input channels # See: https://rasa.com/docs/rasa/messaging-and-voice-channels |
| rasa.settings.credentials.enabled | bool | `true` | Enable credentials configuration for channel connectors |
| rasa.settings.debugMode | bool | `false` | Enable debug mode |
| rasa.settings.enableAPI | bool | `true` | Enter details in token or (jwtSecret, jwtMethod) to enable either of them |
| rasa.settings.endpoints.actionEndpoint.url | string | `"/webhook"` |  |
| rasa.settings.endpoints.additionalEndpoints | object | `{}` |  |
| rasa.settings.endpoints.eventBroker | object | `{"enabled":true,"type":""}` | See: https://rasa.com/docs/rasa/event-brokers |
| rasa.settings.endpoints.lockStore | object | `{"db":"1","enabled":true,"keyPrefix":"","password":"","port":"","socketTimeout":"","url":"","useSsl":false}` | See: https://rasa.com/docs/rasa/lock-stores |
| rasa.settings.endpoints.models | object | `{"enabled":true,"token":{"enabled":true,"secretKey":"","secretName":""},"url":"","waitTimeBetweenPulls":20}` | See: https://rasa.com/docs/rasa/model-storage |
| rasa.settings.endpoints.trackerStore | object | `{"enabled":true,"type":"dynamo"}` | See: https://rasa.com/docs/rasa/tracker-stores |
| rasa.settings.initialModel | string | `""` | Initial model to download and load if a model server or remote storage is not used. It has to be a URL (without auth) that points to a tar.gz file |
| rasa.settings.jwtMethod | string | `"HS256"` | JWT Algorithm |
| rasa.settings.jwtSecret | object | `{"secretKey":"","secretName":""}` | JWT Token |
| rasa.settings.port | int | `5005` | Port on which Rasa runs |
| rasa.settings.scheme | string | `"http"` | Scheme by which the service are accessible |
| rasa.settings.telemetry.debug | bool | `false` |  |
| rasa.settings.telemetry.enabled | bool | `true` | Enable telemetry See: https://rasa.com/docs/rasa/telemetry/telemetry/ |
| rasa.settings.token | object | `{"secretKey":"","secretName":""}` | Token Rasa accepts as authentication token from other Rasa services |
| rasa.settings.trainInitialModel | bool | `false` | Train a model if an initial model is not defined. This parameter is ignored if the `applicationSettings.initialModel` is defined |
| rasa.strategy | object | `{}` | Allow the deployment to perform a rolling update # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| rasa.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| rasa.volumeMounts | list | `[]` | Specify additional volumes to mount in the rasa-oss container |
| rasa.volumes | list | `[]` | Specify additional volumes to mount in the rasa-oss container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| rasaProServices.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| rasaProServices.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Specifies the HPA settings |
| rasaProServices.autoscaling.enabled | bool | `false` | Specifies whether autoscaling should be enabled |
| rasaProServices.autoscaling.maxReplicas | int | `100` | Specifies the maximum number of replicas |
| rasaProServices.autoscaling.minReplicas | int | `1` | Specifies the minimum number of replicas |
| rasaProServices.autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the target CPU/Memory utilization percentage |
| rasaProServices.enabled | bool | `true` | Enable Rasa Pro Services deployment |
| rasaProServices.environmentVariables.KAFKA_BROKER_ADDRESS | object | `{"value":""}` | address of the Kafka broker. |
| rasaProServices.environmentVariables.KAFKA_SASL_MECHANISM | object | `{"value":"PLAIN"}` | SASL mechanism to use for authentication. |
| rasaProServices.environmentVariables.KAFKA_SASL_PASSWORD | object | `{"secret":{"key":null,"name":null}}` | password for SASL authentication |
| rasaProServices.environmentVariables.KAFKA_SASL_USERNAME | object | `{"value":""}` | username for SASL authentication. |
| rasaProServices.environmentVariables.KAFKA_SECURITY_PROTOCOL | object | `{"value":"PLAINTEXT"}` | security protocol to use for communication with Kafka |
| rasaProServices.environmentVariables.KAFKA_SSL_CA_LOCATION | object | `{"value":""}` | filepath for SSL CA Certificate that will be used to connect with Kafka |
| rasaProServices.environmentVariables.KAFKA_TOPIC | object | `{"value":"rasa_core_events"}` | topic Rasa Plus publishes events to and Rasa Pro consumes from |
| rasaProServices.environmentVariables.LOGGING_LEVEL | object | `{"value":"INFO"}` | Set the log level of the application |
| rasaProServices.environmentVariables.RASA_ANALYTICS_DB_URL | object | `{"value":""}` | URL of the data lake to store analytics data in |
| rasaProServices.environmentVariables.RASA_PRO_LICENSE | object | `{"secret":{"key":null,"name":null}}` | license key for Rasa Pro Services. |
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
