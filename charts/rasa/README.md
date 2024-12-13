# rasa

A Rasa Pro Helm chart for Kubernetes

![Version: 1.2.0-rc5](https://img.shields.io/badge/Version-1.2.0--rc5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version 1.2.0-rc5
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Pull the Chart

To pull chart contents for your own convenience:

```console
helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version 1.2.0-rc5
```

## General Configuration

- **imagePullSecrets**: If you're using a private Docker registry, provide the necessary credentials in this section.
- **rasaProLicense**: If you are using Plus or Pro, please provide `secretName` and `secretKey` of your license.

> **Note:** For application specific settings, please refer to our [documentation](https://rasa.com/docs/) and bellow you can find the full list of values.

### Rasa Pro

To deploy Rasa Pro with Analytics, set `rasa.enabled: true` and `rasaProServices.enabled: true`. Configure image and image pull settings.

```yaml
rasa:
  enabled: true
  # Other settings...
rasaProServices:
  enabled: true
```

### Rasa Pro only

Deploy Rasa Plus by setting `rasa.enabled: true`. Adjust image and image pull settings accordingly.

```yaml
rasa:
  enabled: true
  # Other settings...
rasaProServices:
  enabled: false
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| actionServer.additionalContainers | list | `[]` | actionServer.additionalContainers allows to specify additional containers for the Action Server Deployment |
| actionServer.additionalEnv | list | `[]` | actionServer.additionalEnv adds additional environment variables |
| actionServer.affinity | object | `{}` | actionServer.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| actionServer.args | list | `[]` | actionServer.args overrides the default arguments for the container |
| actionServer.autoscaling.enabled | bool | `false` | autoscaling.enabled specifies whether autoscaling should be enabled |
| actionServer.autoscaling.maxReplicas | int | `100` | autoscaling.maxReplicas specifies the maximum number of replicas |
| actionServer.autoscaling.minReplicas | int | `1` | autoscaling.minReplicas specifies the minimum number of replicas |
| actionServer.autoscaling.targetCPUUtilizationPercentage | int | `80` | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage |
| actionServer.command | list | `[]` | actionServer.command overrides the default command for the container |
| actionServer.containerSecurityContext | object | `{"enabled":true}` | actionServer.containerSecurityContext defines security context that allows you to overwrite the container-level security context |
| actionServer.enabled | bool | `false` | actionServer.enabled enables Action Server deployment |
| actionServer.envFrom | list | `[]` | actionServer.envFrom is used to add environment variables from ConfigMap or Secret |
| actionServer.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| actionServer.image.repository | string | `"rasa/rasa-sdk"` | image.repository specifies image repository |
| actionServer.image.tag | string | `"3.6.2"` | image.tag specifies image tag |
| actionServer.ingress.annotations | object | `{}` | ingress.annotations defines annotations to add to the ingress |
| actionServer.ingress.className | string | `""` | ingress.className specifies the ingress className to be used |
| actionServer.ingress.enabled | bool | `false` | ingress.enabled specifies whether an ingress service should be created |
| actionServer.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}]` | ingress.hosts specifies the hosts for this ingress |
| actionServer.ingress.labels | object | `{}` | ingress.lables defines labels to add to the ingress |
| actionServer.ingress.tls | list | `[]` | ingress.tls spefices the TLS configuration for ingress |
| actionServer.initContainers | list | `[]` | actionServer.initContainers allows to specify init containers for the Action Server deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ |
| actionServer.livenessProbe.enabled | bool | `true` | livenessProbe.enabled is used to enable or disable liveness probe |
| actionServer.livenessProbe.failureThreshold | int | `6` | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| actionServer.livenessProbe.httpGet | object | `{"path":"/health","port":5055,"scheme":"HTTP"}` | livenessProbe.httpGet is used to define HTTP request |
| actionServer.livenessProbe.initialDelaySeconds | int | `15` | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| actionServer.livenessProbe.periodSeconds | int | `15` | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| actionServer.livenessProbe.successThreshold | int | `1` | livenessProbe.successThreshold defines how often (in seconds) to perform the probe |
| actionServer.livenessProbe.terminationGracePeriodSeconds | int | `30` | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container |
| actionServer.livenessProbe.timeoutSeconds | int | `5` | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| actionServer.nodeSelector | object | `{}` | actionServer.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| actionServer.podAnnotations | object | `{}` | actionServer.podAnnotations defines annotations to add to the pod |
| actionServer.podSecurityContext | object | `{"enabled":true}` | actionServer.podSecurityContext defines pod security context |
| actionServer.readinessProbe.enabled | bool | `true` | readinessProbe.enabled is used to enable or disable readinessProbe |
| actionServer.readinessProbe.failureThreshold | int | `6` | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| actionServer.readinessProbe.httpGet | object | `{"path":"/health","port":5055,"scheme":"HTTP"}` | readinessProbe.httpGet is used to define HTTP request |
| actionServer.readinessProbe.initialDelaySeconds | int | `15` | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| actionServer.readinessProbe.periodSeconds | int | `15` | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| actionServer.readinessProbe.successThreshold | int | `1` | readinessProbe.successThreshold defines how often (in seconds) to perform the probe |
| actionServer.readinessProbe.timeoutSeconds | int | `5` | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| actionServer.replicaCount | int | `1` | actionServer.replicaCount specifies number of replicas |
| actionServer.resources | object | `{}` | actionServer.resources specifies the resources limits and requests |
| actionServer.service | object | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":5055,"targetPort":5055,"type":"ClusterIP"}` | actionServer.service define service for Action Server |
| actionServer.service.annotations | object | `{}` | service.annotations defines annotations to add to the service |
| actionServer.service.externalTrafficPolicy | string | `"Cluster"` | service.externalTrafficPolicy enables client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip |
| actionServer.service.loadBalancerIP | string | `nil` | service.loadBalancerIP exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer |
| actionServer.service.nodePort | string | `nil` | service.nodePort is used to specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport |
| actionServer.service.port | int | `5055` | service.port is used to specify service port |
| actionServer.service.targetPort | int | `5055` | service.targetPort is ued to specify service target port |
| actionServer.service.type | string | `"ClusterIP"` | service.type is used to specify service type |
| actionServer.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | actionServer.serviceAccount defines service account |
| actionServer.serviceAccount.annotations | object | `{}` | serviceAccount.annotations defines annotations to add to the service account |
| actionServer.serviceAccount.create | bool | `true` | serviceAccount.create specifies whether a service account should be created |
| actionServer.serviceAccount.name | string | `""` | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| actionServer.settings.port | int | `5055` | settings.port defines port on which Action Server runs |
| actionServer.settings.scheme | string | `"http"` | settings.scheme defines sheme by which the service are accessible |
| actionServer.strategy | object | `{}` | actionServer.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| actionServer.tolerations | list | `[]` | actionServer.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| actionServer.volumeMounts | list | `[]` | actionServer.volumeMounts specifies additional volumes to mount in the Action Server container |
| actionServer.volumes | list | `[]` | actionServer.volumes specify additional volumes to mount in the Action Server container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| deploymentAnnotations | object | `{}` | deploymentAnnotations defines annotations to add to all Rasa deployments |
| deploymentLabels | object | `{}` | deploymentLabels defines labels to add to all Rasa deployment |
| dnsConfig | object | `{}` | dnsConfig specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | dnsPolicy specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| duckling.additionalContainers | list | `[]` | duckling.additionalContainers allows to specify additional containers for the Duckling Deployment |
| duckling.additionalEnv | list | `[]` | duckling.additionalEnv adds additional environment variables |
| duckling.affinity | object | `{}` | duckling.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| duckling.args | list | `[]` | duckling.args overrides the default arguments for the container |
| duckling.autoscaling.enabled | bool | `false` | autoscaling.enabled specifies whether autoscaling should be enabled |
| duckling.autoscaling.maxReplicas | int | `100` | autoscaling.maxReplicas specifies the maximum number of replicas |
| duckling.autoscaling.minReplicas | int | `1` | autoscaling.minReplicas specifies the minimum number of replicas |
| duckling.autoscaling.targetCPUUtilizationPercentage | int | `80` | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage |
| duckling.command | list | `[]` | duckling.command overrides the default command for the container |
| duckling.containerSecurityContext | object | `{"enabled":true}` | duckling.containerSecurityContext defines security context that allows you to overwrite the container-level security context |
| duckling.enabled | bool | `false` | duckling.enabled enables Duckling deployment |
| duckling.envFrom | list | `[]` | duckling.envFrom is used to add environment variables from ConfigMap or Secret |
| duckling.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| duckling.image.repository | string | `"rasa/duckling"` | image.repository specifies image repository |
| duckling.image.tag | string | `"0.2.0.2-r0"` | image.tag specifies image tag |
| duckling.ingress.annotations | object | `{}` | ingress.annotations defines annotations to add to the ingress |
| duckling.ingress.className | string | `""` | ingress.className specifies the ingress className to be used |
| duckling.ingress.enabled | bool | `false` | ingress.enabled specifies whether an ingress service should be created |
| duckling.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}]` | ingress.hosts specifies the hosts for this ingress |
| duckling.ingress.labels | object | `{}` | ingress.lables defines labels to add to the ingress |
| duckling.ingress.tls | list | `[]` | ingress.tls spefices the TLS configuration for ingress |
| duckling.initContainers | list | `[]` | duckling.initContainers allows to specify init containers for the Duckling deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ |
| duckling.livenessProbe.enabled | bool | `true` | livenessProbe.enabled is used to enable or disable liveness probe |
| duckling.livenessProbe.failureThreshold | int | `6` | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| duckling.livenessProbe.httpGet | object | `{"path":"/","port":8000,"scheme":"HTTP"}` | livenessProbe.httpGet is used to define HTTP request |
| duckling.livenessProbe.initialDelaySeconds | int | `15` | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| duckling.livenessProbe.periodSeconds | int | `15` | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| duckling.livenessProbe.successThreshold | int | `1` | livenessProbe.successThreshold defines how often (in seconds) to perform the probe |
| duckling.livenessProbe.terminationGracePeriodSeconds | int | `30` | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container |
| duckling.livenessProbe.timeoutSeconds | int | `5` | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| duckling.nodeSelector | object | `{}` | duckling.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| duckling.podAnnotations | object | `{}` | duckling.podAnnotations defines annotations to add to the pod |
| duckling.podSecurityContext | object | `{"enabled":true}` | duckling.podSecurityContext defines pod security context |
| duckling.readinessProbe.enabled | bool | `true` | readinessProbe.enabled is used to enable or disable readinessProbe |
| duckling.readinessProbe.failureThreshold | int | `6` | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| duckling.readinessProbe.httpGet | object | `{"path":"/","port":8000,"scheme":"HTTP"}` | readinessProbe.httpGet is used to define HTTP request |
| duckling.readinessProbe.initialDelaySeconds | int | `15` | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| duckling.readinessProbe.periodSeconds | int | `15` | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| duckling.readinessProbe.successThreshold | int | `1` | readinessProbe.successThreshold defines how often (in seconds) to perform the probe |
| duckling.readinessProbe.timeoutSeconds | int | `5` | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| duckling.replicaCount | int | `1` | duckling.replicaCount specifies number of replicas |
| duckling.resources | object | `{}` | duckling.resources specifies the resources limits and requests |
| duckling.service | object | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":8000,"targetPort":8000,"type":"ClusterIP"}` | duckling.service define service for Duckling |
| duckling.service.annotations | object | `{}` | service.annotations defines annotations to add to the service |
| duckling.service.externalTrafficPolicy | string | `"Cluster"` | service.externalTrafficPolicy enables client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip |
| duckling.service.loadBalancerIP | string | `nil` | service.loadBalancerIP exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer |
| duckling.service.nodePort | string | `nil` | service.nodePort is used to specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport |
| duckling.service.port | int | `8000` | service.port is used to specify service port |
| duckling.service.targetPort | int | `8000` | service.targetPort is ued to specify service target port |
| duckling.service.type | string | `"ClusterIP"` | service.type is used to specify service type |
| duckling.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | duckling.serviceAccount defines service account |
| duckling.serviceAccount.annotations | object | `{}` | serviceAccount.annotations defines annotations to add to the service account |
| duckling.serviceAccount.create | bool | `true` | serviceAccount.create specifies whether a service account should be created |
| duckling.serviceAccount.name | string | `""` | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| duckling.settings.port | int | `8000` | settings.port defines port on which Duckling runs |
| duckling.settings.scheme | string | `"http"` | settings.scheme defines sheme by which the service are accessible |
| duckling.strategy | object | `{}` | duckling.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| duckling.tolerations | list | `[]` | duckling.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| duckling.volumeMounts | list | `[]` | duckling.volumeMounts specifies additional volumes to mount in the Duckling container |
| duckling.volumes | list | `[]` | duckling.volumes specify additional volumes to mount in the Duckling container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| fullnameOverride | string | `""` | fullnameOverride overrides the full qualified app name |
| global.additionalDeploymentLabels | object | `{}` | global.additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| global.ingressHost | string | `nil` |  |
| hostAliases | list | `[]` | hostAliases specifies pod-level override of hostname resolution when DNS and other options are not applicable |
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
| rasa.containerSecurityContext | object | `{"enabled":true}` | rasa.containerSecurityContext defines security context that allows you to overwrite the container-level security context |
| rasa.enabled | bool | `true` | rasa.enabled enables Rasa Plus deployment Disable this if you want to deploy ONLY Rasa Pro Services |
| rasa.envFrom | list | `[]` | rasa.envFrom is used to add environment variables from ConfigMap or Secret |
| rasa.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| rasa.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` | image.repository specifies image repository |
| rasa.image.tag | string | `"3.8.10-latest"` | image.tag specifies image tag |
| rasa.ingress.annotations | object | `{}` | ingress.annotations defines annotations to add to the ingress |
| rasa.ingress.className | string | `""` | ingress.className specifies the ingress className to be used |
| rasa.ingress.enabled | bool | `false` | ingress.enabled specifies whether an ingress service should be created |
| rasa.ingress.hosts | list | `[{"extraPaths":[],"host":"INGRESS.HOST.NAME","paths":[{"path":"/api","pathType":"Prefix"}]}]` | ingress.hosts specifies the hosts for this ingress |
| rasa.ingress.labels | object | `{}` | ingress.lables defines labels to add to the ingress |
| rasa.ingress.tls | list | `[]` | ingress.tls spefices the TLS configuration for ingress |
| rasa.initContainers | list | `[]` | rasa.initContainers allows to specify init containers for the Rasa deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ # <PATH_TO_INITIAL_MODEL> has to be a URL (without auth) that points to a tar.gz file |
| rasa.livenessProbe.enabled | bool | `true` | livenessProbe.enabled is used to enable or disable liveness probe |
| rasa.livenessProbe.failureThreshold | int | `6` | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| rasa.livenessProbe.httpGet | object | `{"path":"/","port":5005,"scheme":"HTTP"}` | livenessProbe.httpGet is used to define HTTP request |
| rasa.livenessProbe.initialDelaySeconds | int | `15` | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| rasa.livenessProbe.periodSeconds | int | `15` | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| rasa.livenessProbe.successThreshold | int | `1` | livenessProbe.successThreshold defines how often (in seconds) to perform the probe |
| rasa.livenessProbe.terminationGracePeriodSeconds | int | `30` | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container |
| rasa.livenessProbe.timeoutSeconds | int | `5` | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| rasa.nodeSelector | object | `{}` | rasa.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| rasa.overrideEnv | list | `[]` | rasa.overrideEnv overrides all default environment variables |
| rasa.persistence.create | bool | `false` |  |
| rasa.persistence.hostPath.enabled | bool | `false` |  |
| rasa.persistence.storageCapacity | string | `"1Gi"` |  |
| rasa.persistence.storageClassName | string | `nil` |  |
| rasa.persistence.storageRequests | string | `"1Gi"` |  |
| rasa.podAnnotations | object | `{}` | rasa.podAnnotations defines annotations to add to the pod |
| rasa.podSecurityContext | object | `{"enabled":true}` | rasa.podSecurityContext defines pod security context |
| rasa.readinessProbe.enabled | bool | `true` | readinessProbe.enabled is used to enable or disable readinessProbe |
| rasa.readinessProbe.failureThreshold | int | `6` | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| rasa.readinessProbe.httpGet | object | `{"path":"/","port":5005,"scheme":"HTTP"}` | readinessProbe.httpGet is used to define HTTP request |
| rasa.readinessProbe.initialDelaySeconds | int | `15` | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| rasa.readinessProbe.periodSeconds | int | `15` | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| rasa.readinessProbe.successThreshold | int | `1` | readinessProbe.successThreshold defines how often (in seconds) to perform the probe |
| rasa.readinessProbe.timeoutSeconds | int | `5` | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| rasa.replicaCount | int | `1` | rasa.replicaCount specifies number of replicas |
| rasa.resources | object | `{}` | rasa.resources specifies the resources limits and requests |
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
| rasa.settings.authToken | object | `{"secretKey":"authToken","secretName":"rasa-secrets"}` | settings.authToken is token Rasa accepts as authentication token from other Rasa services |
| rasa.settings.cors | string | `"*"` | settings.cors is CORS for the passed origin. Default is * to allow all origins |
| rasa.settings.credentials.additionalChannelCredentials | object | `{}` | credentials.additionalChannelCredentials defines credentials which should be used by Rasa to connect to various input channels # See: https://rasa.com/docs/rasa/messaging-and-voice-channels |
| rasa.settings.credentials.enabled | bool | `false` | credentials.enabled enables credentials configuration for channel connectors |
| rasa.settings.debugMode | bool | `false` | settings.debugMode enables debug mode |
| rasa.settings.ducklingHttpUrl | string | `nil` | settings.ducklingHttpUrl is HTTP URL to the duckling service |
| rasa.settings.enableApi | bool | `true` | settings.enableApi start the web server API in addition to the input channel Rasa API supports two authentication methods, Token based Auth or JWT Enter details in token or (jwtSecret, jwtMethod) to enable either of them |
| rasa.settings.endpoints.actionEndpoint.url | string | `"/webhook"` |  |
| rasa.settings.endpoints.additionalEndpoints | object | `{}` | `endpoints.additionalEndpoints` to add more settings to `endpoints.yml` |
| rasa.settings.endpoints.eventBroker | object | `{"enabled":false}` | endpoints.eventBroker allows you to connect your running assistant to other services that process the data See: https://rasa.com/docs/rasa/event-brokers |
| rasa.settings.endpoints.lockStore | object | `{"enabled":false,"url":"","useConcurrent":true}` | endpoints.lockStore makes lock mechanism to ensure that incoming messages for a given conversation ID are processed in the right order See: https://rasa.com/docs/rasa/lock-stores |
| rasa.settings.endpoints.models | object | `{"enabled":false}` | endpoints.models provides loading models from the storage See: https://rasa.com/docs/rasa/model-storage |
| rasa.settings.endpoints.tracing | object | `{"enabled":false}` | endpoints.tracing tracks requests as they flow through a distributed system See: https://rasa.com/docs/rasa/monitoring/tracing/ |
| rasa.settings.endpoints.trackerStore | object | `{"enabled":false}` | endpoints.trackerStore assistant's conversations are stored within a tracker store See: https://rasa.com/docs/rasa/tracker-stores |
| rasa.settings.environment | string | `"development"` | settings.environment: development or production |
| rasa.settings.jwtMethod | string | `"HS256"` | settings.jwtMethod is JWT algorithm to be used |
| rasa.settings.jwtSecret | object | `{"secretKey":"jwtSecret","secretName":"rasa-secrets"}` | settings.jwtSecret is JWT token Rasa accepts as authentication token from other Rasa services |
| rasa.settings.logging.logLevel | string | `"info"` | logging.logLevel is Rasa Log Level |
| rasa.settings.mountDefaultConfigmap | bool | `true` | settings.mountVolumes is a flag to disable mounting of credentials.yml and endpoints.yml to the Rasa Pro deployment. |
| rasa.settings.port | int | `5005` | settings.port defines port on which Rasa runs |
| rasa.settings.scheme | string | `"http"` | settings.scheme defines scheme by which the service are accessible |
| rasa.settings.telemetry.debug | bool | `false` | telemetry.debug prints telemetry data to stdout |
| rasa.settings.telemetry.enabled | bool | `true` | telemetry.enabled allow Rasa to collect anonymous usage details |
| rasa.settings.useDefaultArgs | bool | `true` | settings.useDefaultArgs is to disable default startup args to be able to be used by Studio. There is no need to ever disable this in Rasa Pro case. |
| rasa.strategy | object | `{}` | rasa.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| rasa.tolerations | list | `[]` | rasa.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| rasa.volumeMounts | list | `[]` | rasa.volumeMounts specifies additional volumes to mount in the Rasa container |
| rasa.volumes | list | `[]` | rasa.volumes specify additional volumes to mount in the Rasa container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ |
| rasaProLicense | object | `{"secretKey":"rasaProLicense","secretName":"rasa-secrets"}` | rasaProLicense is license key for Rasa Pro Services. |
| rasaProServices.additionalContainers | list | `[]` | rasaProServices.additionalContainers allows to specify additional containers for the Rasa Pro Services Deployment |
| rasaProServices.affinity | object | `{}` | rasaProServices.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| rasaProServices.autoscaling.enabled | bool | `false` | autoscaling.enabled specifies whether autoscaling should be enabled |
| rasaProServices.autoscaling.maxReplicas | int | `100` | autoscaling.maxReplicas specifies the maximum number of replicas |
| rasaProServices.autoscaling.minReplicas | int | `1` | autoscaling.minReplicas specifies the minimum number of replicas |
| rasaProServices.autoscaling.targetCPUUtilizationPercentage | int | `80` | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage |
| rasaProServices.containerSecurityContext | object | `{"enabled":true}` | rasaProServices.containerSecurityContext defines security context that allows you to overwrite the container-level security context |
| rasaProServices.enabled | bool | `true` | rasaProServices.enabled enables Rasa Pro Services deployment |
| rasaProServices.envFrom | list | `[]` | rasaProServices.envFrom is used to add environment variables from ConfigMap or Secret |
| rasaProServices.environmentVariables.KAFKA_BROKER_ADDRESS.value | string | `""` |  |
| rasaProServices.environmentVariables.KAFKA_SASL_MECHANISM.value | string | `"PLAIN"` |  |
| rasaProServices.environmentVariables.KAFKA_SASL_PASSWORD.secret.key | string | `"kafkaSslPassword"` |  |
| rasaProServices.environmentVariables.KAFKA_SASL_PASSWORD.secret.name | string | `"rasa-secrets"` |  |
| rasaProServices.environmentVariables.KAFKA_SASL_USERNAME.value | string | `""` |  |
| rasaProServices.environmentVariables.KAFKA_SECURITY_PROTOCOL.value | string | `"PLAINTEXT"` |  |
| rasaProServices.environmentVariables.KAFKA_SSL_CA_LOCATION.value | string | `""` |  |
| rasaProServices.environmentVariables.KAFKA_TOPIC.value | string | `"rasa-core-events"` |  |
| rasaProServices.environmentVariables.LOGGING_LEVEL.value | string | `"INFO"` |  |
| rasaProServices.environmentVariables.RASA_ANALYTICS_DB_URL.value | string | `""` |  |
| rasaProServices.image.pullPolicy | string | `"IfNotPresent"` | image.pullPolicy specifies image pull policy |
| rasaProServices.image.repository | string | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro-services"` | image.repository specifies image repository |
| rasaProServices.image.tag | string | `"3.2.3-latest"` | Specifies image tag image.tag specifies image tag |
| rasaProServices.imagePullSecrets | list | `[]` | imagePullSecrets is used for private repository pull secrets # If this is not set, global `imagePullSecrets` will be applied. If both are set, this takes priority. |
| rasaProServices.livenessProbe.enabled | bool | `true` | livenessProbe.enabled is used to enable or disable liveness probe |
| rasaProServices.livenessProbe.failureThreshold | int | `6` | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy |
| rasaProServices.livenessProbe.httpGet | object | `{"path":"/healthcheck","port":8732,"scheme":"HTTP"}` | livenessProbe.httpGet is used to define HTTP request |
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
| rasaProServices.readinessProbe.httpGet | object | `{"path":"/healthcheck","port":8732,"scheme":"HTTP"}` | readinessProbe.httpGet is used to define HTTP request |
| rasaProServices.readinessProbe.initialDelaySeconds | int | `15` | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe |
| rasaProServices.readinessProbe.periodSeconds | int | `15` | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds |
| rasaProServices.readinessProbe.successThreshold | int | `1` | readinessProbe.successThreshold defines how often (in seconds) to perform the probe |
| rasaProServices.readinessProbe.timeoutSeconds | int | `5` | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out |
| rasaProServices.replicaCount | int | `1` | rasaProServices.replicaCount specifies number of replicas |
| rasaProServices.resources | object | `{}` | rasaProServices.resources specifies the resources limits and requests |
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
