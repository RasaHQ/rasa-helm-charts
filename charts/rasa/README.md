# rasa

A Rasa Pro Helm chart for Kubernetes

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://registry-1.docker.io/helm-charts/rasa --version 0.1.2
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
$ helm pull oci://registry-1.docker.io/helm-charts/rasa --version 0.1.2
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| actionServer.external.enabled | bool | `false` | Determine if external URL is used |
| actionServer.external.url | string | `""` | External URL to Rasa Action Server |
| actionServer.install | bool | `false` | Install Rasa Action Server |
| deploymentAnnotations | object | `{}` | deploymentAnnotations defines annotations to add to all Rasa deployments |
| deploymentLabels | object | `{}` | deploymentLabels defines labels to add to all Rasa deployment |
| dnsConfig | object | `{}` | dnsConfig specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | dnsPolicy specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| duckling.external.enabled | bool | `false` | Determine if external URL is used |
| duckling.external.url | string | `""` | External URL to Duckling |
| duckling.install | bool | `false` | Install Duckling |
| fullnameOverride | string | `""` | fullnameOverride overrides the full qualified app name |
| global.additionalDeploymentLabels | object | `{}` | global.additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| hostNetwork | bool | `false` | hostNetwork controls whether the pod may use the node network namespace |
| imagePullSecrets | list | `[]` | imagePullSecrets is used for private repository pull secrets |
| nameOverride | string | `""` | nameOverride overrides name of the app |
| networkPolicy.denyAll | bool | `false` | Specifies whether to apply denyAll network policy |
| networkPolicy.enabled | bool | `false` | Specifies whether to enable network policies |
| networkPolicy.nodeCIDR | list | `[]` | Allow for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes |
| podLabels | object | `{}` | podLabels defines labels to add to all Rasa pod(s) |
| rasa.additionalArgs | list | `[]` | rasa.additionalArgs adds additional arguments to the default args |
| rasa.additionalContainers | list | `[]` | rasa.additionalContainers allows to specify additional containers for the Rasa Deployment |
| rasa.additionalEnv | list | `[]` | rasa.additionalEnv adds additional environment variables |
| rasa.affinity | object | `{}` | rasa.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| rasa.args | list | `[]` | rasa.args overrides the default arguments for the container |
| rasa.autoscaling.enabled | bool | `false` | autoscaling.enabled specifies whether autoscaling should be enabled |
| rasa.autoscaling.maxReplicas | int | `100` | autoscaling.maxReplicas specifies the maximum number of replicas |
| rasa.autoscaling.minReplicas | int | `1` | autoscaling.minReplicas specifies the minimum number of replicas |
| rasa.autoscaling.targetCPUUtilizationPercentage | int | `80` | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage |
| rasa.command | list | `[]` | rasa.command overrides the default command for the container |
| rasa.enabled | bool | `true` | rasa.enabled enables Rasa OSS/Plus deployment Disable this if you want to deploy ONLY Rasa Pro Services |
| rasa.envFrom | list | `[]` | rasa.envFrom is used to add environment variables from ConfigMap or Secret |
| rasa.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| rasa.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-plus/rasa-plus"` | image.repository specifies image repository |
| rasa.image.tag | string | `"3.6.4-latest"` | image.tag specifies image tag |
| rasa.ingress.annotations | object | `{}` | ingress.annotations defines annotations to add to the ingress |
| rasa.ingress.className | string | `""` | ingress.className specifies the ingress className to be used |
| rasa.ingress.enabled | bool | `false` | ingress.enabled specifies whether an ingress service should be created |
| rasa.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}]` | ingress.hosts specifies the hosts for this ingress |
| rasa.ingress.labels | object | `{}` | ingress.lables defines labels to add to the ingress |
| rasa.ingress.tls | list | `[]` | ingress.tls spefices the TLS configuration for ingress |
| rasa.initContainers | list | `[]` | rasa.initContainers allows to specify init containers for the Rasa deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ # <PATH_TO_INITIAL_MODEL> has to be a URL (without auth) that points to a tar.gz file |
| rasa.livenessProbe.enabled | bool | `true` | livenessProbe.enabled is used to enable or disable liveness probe |
| rasa.livenessProbe.failureThreshold | int | `6` | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| rasa.livenessProbe.httpGet | object | `{"path":"/","port":80,"scheme":"HTTP"}` | livenessProbe.httpGet is used to define HTTP request |
| rasa.livenessProbe.initialDelaySeconds | int | `15` | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| rasa.livenessProbe.periodSeconds | int | `15` | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| rasa.livenessProbe.successThreshold | int | `1` | livenessProbe.successThreshold defines how often (in seconds) to perform the probe |
| rasa.livenessProbe.terminationGracePeriodSeconds | int | `30` | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container |
| rasa.livenessProbe.timeoutSeconds | int | `5` | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| rasa.nodeSelector | object | `{}` | rasa.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| rasa.plus.enabled | bool | `true` | plus.enabled enabled Rasa Plus drop-in replacement of Rasa |
| rasa.podAnnotations | object | `{}` | rasa.podAnnotations defines annotations to add to the pod |
| rasa.podSecurityContext | object | `{"enabled":true}` | rasa.podSecurityContext defines pod security context |
| rasa.readinessProbe.enabled | bool | `true` | readinessProbe.enabled is used to enable or disable readinessProbe |
| rasa.readinessProbe.failureThreshold | int | `6` | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| rasa.readinessProbe.httpGet | object | `{"path":"/","port":80,"scheme":"HTTP"}` | readinessProbe.httpGet is used to define HTTP request |
| rasa.readinessProbe.initialDelaySeconds | int | `15` | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| rasa.readinessProbe.periodSeconds | int | `15` | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| rasa.readinessProbe.successThreshold | int | `1` | readinessProbe.successThreshold defines how often (in seconds) to perform the probe |
| rasa.readinessProbe.terminationGracePeriodSeconds | int | `30` | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container |
| rasa.readinessProbe.timeoutSeconds | int | `5` | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| rasa.replicaCount | int | `1` | rasa.replicaCount specifies number of replicas |
| rasa.resources | object | `{}` | rasa.resources specifies the resources limits and requests |
| rasa.securityContext | object | `{"enabled":true}` | rasa.securityContext defines security context that allows you to overwrite the pod-level security context |
| rasa.service | object | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":5005,"targetPort":5005,"type":"ClusterIP"}` | rasa.service define service for Rasa OSS/Plus |
| rasa.service.annotations | object | `{}` | service.annotations defines annotations to add to the service |
| rasa.service.externalTrafficPolicy | string | `"Cluster"` | service.externalTrafficPolicy enables client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip |
| rasa.service.loadBalancerIP | string | `nil` | service.loadBalancerIP exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer |
| rasa.service.nodePort | string | `nil` | service.nodePort is used to specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport |
| rasa.service.port | int | `5005` | service.port is used to specify service port |
| rasa.service.targetPort | int | `5005` | service.targetPort is ued to specify service target port |
| rasa.service.type | string | `"ClusterIP"` | service.type is used to specify service type |
| rasa.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | rasa.serviceAccount defines service account |
| rasa.serviceAccount.annotations | object | `{}` | serviceAccount.annotations defines annotations to add to the service account |
| rasa.serviceAccount.create | bool | `true` | serviceAccount.create specifies whether a service account should be created |
| rasa.serviceAccount.name | string | `""` | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| rasa.settings.authToken | object | `{"secretKey":"","secretName":""}` | settings.authToken is token Rasa accepts as authentication token from other Rasa services |
| rasa.settings.cache | object | `{"directory":null,"maxSize":1000,"name":"cache.db"}` | settings.cache is used for `rasa train` command |
| rasa.settings.cache.directory | string | `nil` | cache.default is location of the cache default is equivalent of Path(".rasa", "cache") |
| rasa.settings.cache.maxSize | int | `1000` | cache.maxSize is maximum size for the cache |
| rasa.settings.cache.name | string | `"cache.db"` | cache.name is the name of the cache file |
| rasa.settings.cors | string | `"*"` | settings.cors is CORS for the passed origin. Default is * to allow all origins |
| rasa.settings.credentials.additionalChannelCredentials | object | `{}` | credentials.additionalChannelCredentials defines credentials which should be used by Rasa to connect to various input channels # See: https://rasa.com/docs/rasa/messaging-and-voice-channels |
| rasa.settings.credentials.enabled | bool | `false` | credentials.enabled enables credentials configuration for channel connectors |
| rasa.settings.debugMode | bool | `false` | settings.debugMode enables debug mode |
| rasa.settings.ducklingHttpUrl | string | `nil` | settings.ducklingHttpUrl is HTTP URL to the duckling service |
| rasa.settings.enableApi | bool | `true` | settings.enableApi start the web server API in addition to the input channel Rasa API supports two authentication methods, Token based Auth or JWT Enter details in token or (jwtSecret, jwtMethod) to enable either of them |
| rasa.settings.endpoints.actionEndpoint.url | string | `"/webhook"` |  |
| rasa.settings.endpoints.additionalEndpoints | object | `{}` | `endpoints.additionalEndpoints` to add more settings to `endpoints.yml` |
| rasa.settings.endpoints.eventBroker | object | `{"enabled":false}` | endpoints.eventBroker allows you to connect your running assistant to other services that process the data See: https://rasa.com/docs/rasa/event-brokers |
| rasa.settings.endpoints.lockStore | object | `{"db":"1","enabled":false,"keyPrefix":"","password":"","port":"","socketTimeout":"","url":"","useSsl":false}` | endpoints.lockStore makes lock mechanism to ensure that incoming messages for a given conversation ID are processed in the right order See: https://rasa.com/docs/rasa/lock-stores |
| rasa.settings.endpoints.models | object | `{"enabled":false}` | endpoints.models provides loading models from the storage See: https://rasa.com/docs/rasa/model-storage |
| rasa.settings.endpoints.tracing | object | `{"enabled":false}` | endpoints.tracing tracks requests as they flow through a distributed system See: https://rasa.com/docs/rasa/monitoring/tracing/ |
| rasa.settings.endpoints.trackerStore | object | `{"enabled":false}` | endpoints.trackerStore assistant's conversations are stored within a tracker store See: https://rasa.com/docs/rasa/tracker-stores |
| rasa.settings.environment | string | `"development"` | settings.environment: development or production |
| rasa.settings.jwtMethod | string | `"HS256"` | settings.jwtMethod is JWT algorithm to be used |
| rasa.settings.jwtSecret | object | `{"secretKey":"","secretName":""}` | settings.jwtSecret is JWT token Rasa accepts as authentication token from other Rasa services |
| rasa.settings.lockStore | object | `{"ticketLockLifetime":60}` | settings.lockStore provides synchronization mechanism used by Rasa |
| rasa.settings.lockStore.ticketLockLifetime | int | `60` | lockStore.ticketLockLifetime is lifetime of the ticket associated with a lock |
| rasa.settings.logging.forceJsonLogging | bool | `false` | logging.forceJsonLogging forces logging in JSON |
| rasa.settings.logging.logLevel | string | `"info"` | logging.logLevel is Rasa Log Level |
| rasa.settings.logging.logLevelFaker | string | `"error"` | logging.logLevelFaker configures log level for Faker |
| rasa.settings.logging.logLevelKafka | string | `"error"` | logging.logLevelKafka configures log level for Kafka |
| rasa.settings.logging.logLevelLibraries | string | `"error"` | logging.logLevelLibraries configures log level for Tensorflow, asyncio, APScheduler, SocketIO, Matplotlib, RabbitMQ, Kafka |
| rasa.settings.logging.logLevelMatplotlib | string | `"error"` | logging.logLevelMatplotlib configures log level for Matplotlib |
| rasa.settings.logging.logLevelPresidio | string | `"error"` | logging.logLevelPresidio configures log level for Presidio |
| rasa.settings.logging.logLevelRabbitMq | string | `"error"` | logging.logLevelRabbitMq configures log level for RabbitMQ |
| rasa.settings.maxNumberOfPreditions | int | `10` |  |
| rasa.settings.port | int | `5005` | settings.port defines port on which Rasa runs |
| rasa.settings.postgresTrackerStore | object | `{"maxOverflow":100,"poolSize":50,"schema":"public"}` | settings.postgresTrackerStore defines settings to customize connections to Postgres |
| rasa.settings.postgresTrackerStore.maxOverflow | int | `100` | postgresTrackerStore.maxOverflow defines maximum overflow size of the pool |
| rasa.settings.postgresTrackerStore.poolSize | int | `50` | postgresTrackerStore.poolSize defines Pool Size configuration |
| rasa.settings.postgresTrackerStore.schema | string | `"public"` | postgresTrackerStore.shema is PostgreSQL schema to access |
| rasa.settings.rabbitmq | object | `{"enabled":false,"postgresTrackerStore":{"secretKey":null,"secretName":null},"sslClientKey":{"secretKey":null,"secretName":null}}` | settings.rabbitmq defines settings to setup RabbitMQ SSL |
| rasa.settings.rabbitmq.enabled | bool | `false` | rabbitmq.enabled defines if RabbitMq will be used |
| rasa.settings.rabbitmq.postgresTrackerStore | object | `{"secretKey":null,"secretName":null}` | rabbitmq.postgresTrackerStore is path to the SSL client certificate |
| rasa.settings.rabbitmq.sslClientKey | object | `{"secretKey":null,"secretName":null}` | rabbitmq.sslClientKey is path to the SSL client key |
| rasa.settings.sanicServer | object | `{"backlog":100,"workers":1}` | settings.sanicServer defines sanicServer settings |
| rasa.settings.sanicServer.backlog | int | `100` | sanicServer.backlog is number of unaccepted connections the server allows before refusing new connections |
| rasa.settings.sanicServer.workers | int | `1` | sanicServer.workers is number of Sanic worker processes in the HTTP Server and Input Channel Server |
| rasa.settings.scheme | string | `"http"` | settings.scheme defines scheme by which the service are accessible |
| rasa.settings.shellStreamReadingTimeoutInSeconds | int | `10` |  |
| rasa.settings.telemetry.debug | bool | `false` | telemetry.debug prints telemetry data to stdout |
| rasa.settings.telemetry.enabled | bool | `true` | telemetry.enabled allow Rasa to collect anonymous usage details |
| rasa.settings.tensorflow | object | `{"deterministicOps":false,"gpuMemoryAlloc":"0:1024, 1:2048","interOpParallelismThreads":"3","intraOpParallelismThreads":"2"}` | settings.tensorflow defines Tensorflow parameters |
| rasa.settings.tensorflow.deterministicOps | bool | `false` | See: https://rasa.com/docs/rasa/tuning-your-model/#deterministic-operations |
| rasa.settings.tensorflow.gpuMemoryAlloc | string | `"0:1024, 1:2048"` | tensorflow.gpuMemoryAlloc is used to limit the absolute amount of GPU memory that can be used by a Rasa process |
| rasa.settings.tensorflow.interOpParallelismThreads | string | `"3"` | See: https://rasa.com/docs/rasa/tuning-your-model/#parallelizing-one-operation |
| rasa.settings.tensorflow.intraOpParallelismThreads | string | `"2"` | See: https://rasa.com/docs/rasa/tuning-your-model/#parallelizing-multiple-operations |
| rasa.strategy | object | `{}` | rasa.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| rasa.tolerations | list | `[]` | rasa.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| rasa.volumeMounts | list | `[]` | rasa.volumeMounts specifies additional volumes to mount in the Rasa container |
| rasa.volumes | list | `[]` | rasa.volumes specify additional volumes to mount in the Rasa container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| rasaProLicence | object | `{"secretKey":null,"secretName":null}` | rasaProLicence is license key for Rasa Pro Services. |
| rasaProServices.additionalContainers | list | `[]` | rasaProServices.additionalContainers allows to specify additional containers for the Rasa Pro Services Deployment |
| rasaProServices.affinity | object | `{}` | rasaProServices.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| rasaProServices.autoscaling.enabled | bool | `false` | autoscaling.enabled specifies whether autoscaling should be enabled |
| rasaProServices.autoscaling.maxReplicas | int | `100` | autoscaling.maxReplicas specifies the maximum number of replicas |
| rasaProServices.autoscaling.minReplicas | int | `1` | autoscaling.minReplicas specifies the minimum number of replicas |
| rasaProServices.autoscaling.targetCPUUtilizationPercentage | int | `80` | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage |
| rasaProServices.enabled | bool | `true` | rasaProServices.enabled enables Rasa Pro Services deployment |
| rasaProServices.envFrom | list | `[]` | rasaProServices.envFrom is used to add environment variables from ConfigMap or Secret |
| rasaProServices.environmentVariables.KAFKA_BROKER_ADDRESS.value | string | `""` |  |
| rasaProServices.environmentVariables.KAFKA_SASL_MECHANISM.value | string | `"PLAIN"` |  |
| rasaProServices.environmentVariables.KAFKA_SASL_PASSWORD.secret.key | string | `nil` |  |
| rasaProServices.environmentVariables.KAFKA_SASL_PASSWORD.secret.name | string | `nil` |  |
| rasaProServices.environmentVariables.KAFKA_SASL_USERNAME.value | string | `""` |  |
| rasaProServices.environmentVariables.KAFKA_SECURITY_PROTOCOL.value | string | `"PLAINTEXT"` |  |
| rasaProServices.environmentVariables.KAFKA_SSL_CA_LOCATION.value | string | `""` |  |
| rasaProServices.environmentVariables.KAFKA_TOPIC.value | string | `"rasa_core_events"` |  |
| rasaProServices.environmentVariables.LOGGING_LEVEL.value | string | `"INFO"` |  |
| rasaProServices.environmentVariables.RASA_ANALYTICS_DB_URL.value | string | `""` |  |
| rasaProServices.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| rasaProServices.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` | image.repository specifies image repository |
| rasaProServices.image.tag | string | `"3.1.1-latest"` | Specifies image tag image.tag specifies image tag |
| rasaProServices.livenessProbe.enabled | bool | `true` | livenessProbe.enabled is used to enable or disable liveness probe |
| rasaProServices.livenessProbe.failureThreshold | int | `6` | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| rasaProServices.livenessProbe.httpGet | object | `{"path":"/","port":80,"scheme":"HTTP"}` | livenessProbe.httpGet is used to define HTTP request |
| rasaProServices.livenessProbe.initialDelaySeconds | int | `15` | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| rasaProServices.livenessProbe.periodSeconds | int | `15` | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| rasaProServices.livenessProbe.successThreshold | int | `1` | livenessProbe.successThreshold defines how often (in seconds) to perform the probe |
| rasaProServices.livenessProbe.terminationGracePeriodSeconds | int | `30` | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container |
| rasaProServices.livenessProbe.timeoutSeconds | int | `5` | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| rasaProServices.nodeSelector | object | `{}` | rasaProServices.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| rasaProServices.podAnnotations | object | `{}` | rasaProServices.podAnnotations defines annotations to add to the pod |
| rasaProServices.podSecurityContext | object | `{"enabled":true}` | rasaProServices.podSecurityContext defines pod security context |
| rasaProServices.readinessProbe.enabled | bool | `true` | readinessProbe.enabled is used to enable or disable readinessProbe |
| rasaProServices.readinessProbe.failureThreshold | int | `6` | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| rasaProServices.readinessProbe.httpGet | object | `{"path":"/","port":80,"scheme":"HTTP"}` | readinessProbe.httpGet is used to define HTTP request |
| rasaProServices.readinessProbe.initialDelaySeconds | int | `15` | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| rasaProServices.readinessProbe.periodSeconds | int | `15` | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| rasaProServices.readinessProbe.successThreshold | int | `1` | readinessProbe.successThreshold defines how often (in seconds) to perform the probe |
| rasaProServices.readinessProbe.terminationGracePeriodSeconds | int | `30` | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container |
| rasaProServices.readinessProbe.timeoutSeconds | int | `5` | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| rasaProServices.replicaCount | int | `1` | rasaProServices.replicaCount specifies number of replicas |
| rasaProServices.resources | object | `{}` | rasaProServices.resources specifies the resources limits and requests |
| rasaProServices.securityContext | object | `{"enabled":true}` | rasaProServices.securityContext defines security context that allows you to overwrite the pod-level security context |
| rasaProServices.service | object | `{"annotations":{},"port":8732,"targetPort":8732,"type":"ClusterIP"}` | rasaProServices.service define service for Rasa OSS/Plus |
| rasaProServices.service.annotations | object | `{}` | service.annotations defines annotations to add to the service |
| rasaProServices.service.port | int | `8732` | service.port is used to specify service port |
| rasaProServices.service.targetPort | int | `8732` | service.targetPort is ued to specify service target port |
| rasaProServices.service.type | string | `"ClusterIP"` | service.type is used to specify service type |
| rasaProServices.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | rasaProServices.serviceAccount defines service account |
| rasaProServices.serviceAccount.annotations | object | `{}` | serviceAccount.annotations defines annotations to add to the service account |
| rasaProServices.serviceAccount.create | bool | `true` | serviceAccount.create specifies whether a service account should be created |
| rasaProServices.serviceAccount.name | string | `""` | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| rasaProServices.strategy | object | `{}` | rasaProServices.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| rasaProServices.tolerations | list | `[]` | rasaProServices.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| rasaProServices.volumeMounts | list | `[]` | rasaProServices.volumeMounts specifies additional volumes to mount in the Rasa Pro Services container |
| rasaProServices.volumes | list | `[]` | rasaProServices.volumes specify additional volumes for the Rasa Pro Services container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
