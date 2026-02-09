# rasa

A Rasa Pro Helm chart for Kubernetes

![Version: 2.0.2](https://img.shields.io/badge/Version-2.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+

## Installing the Chart

You can install the chart from either the OCI registry or the GitHub Helm repository.

### Option 1: Install from OCI Registry

To install the chart with the release name `my-release`:

```console
helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version 2.0.2
```

### Option 2: Install from GitHub Helm Repository

First, add the Rasa Helm repository:

```console
helm repo add rasa https://helm.rasa.com/charts
helm repo update
```

Then install the chart:

```console
helm install my-release rasa/rasa --version 2.0.2
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Pull the Chart

You can pull the chart from either source:

### From OCI Registry:

```console
helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version 2.0.2
```

### From GitHub Helm Repository:

```console
helm pull rasa/rasa --version 2.0.2
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

### Use MiniO instead of S3

To use MiniO instead of S3, set `AWS_ENDPOINT_URL` environment variable to the URL of the MiniO server along with `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables. Also provide `AWS_REGION` and `BUCKET_NAME` environment variables.

```yaml
rasa:
  additionalEnv:
    - name: AWS_ENDPOINT_URL
      value: "http://minio.example.com"
    - name: AWS_ACCESS_KEY_ID
      value: "minio"
    - name: AWS_SECRET_ACCESS_KEY
      value: "minio123"
    - name: AWS_REGION
      value: "us-east-1"
    - name: BUCKET_NAME
      value: "rasa-models"
```

### Mount Configuration Options

**mountDefaultConfigmap:**

By default, the chart mounts `credentials.yml` and `endpoints.yml` files from a ConfigMap to the Rasa deployment. If you prefer to mount these files from a different source (e.g., from the `/.config` directory or baked into the image), you can disable this behavior:

```yaml
rasa:
  settings:
    mountDefaultConfigmap: false
```

When disabled, it is expected that the credentials and endpoints are mounted to the `/.config` directory or baked into the image.

**mountModelsVolume:**

By default, the chart mounts a models volume to the Rasa deployment at `/app/models`. If you prefer to mount models from a different source or bake them into the image, you can disable this behavior:

```yaml
rasa:
  settings:
    mountModelsVolume: false
```

When disabled, it is expected that the models are mounted to the `/app/models` directory or baked into the image.

### Configuring Credentials and Endpoints via ConfigMap

The chart can automatically create a ConfigMap containing `credentials.yml` and `endpoints.yml` files that are mounted to the Rasa deployment. This is enabled by default via `rasa.settings.mountDefaultConfigmap: true`.

#### Configuring Credentials

The `rasa.settings.credentials` section allows you to configure channel connectors for messaging and voice channels. These credentials are written to the `credentials.yml` file in the ConfigMap.

For example, to configure Facebook Messenger:

```yaml
rasa:
  settings:
    credentials:
      facebook:
        verify: "rasa"
        secret: "<SECRET>"
        page-access-token: "<PAGE-ACCESS-TOKEN>"
```

For REST channel:

```yaml
rasa:
  settings:
    credentials:
      rest:
```

See the [Rasa channel documentation](https://rasa.com/docs/reference/channels/messaging-and-voice-channels) for all available channel configurations.

#### Configuring Endpoints

The `rasa.settings.endpoints` section allows you to configure various endpoints and integrations. These endpoints are written to the `endpoints.yml` file in the ConfigMap.

**Action Server Endpoint:**

```yaml
rasa:
  settings:
    endpoints:
      action_endpoint:
        url: "/webhook"
```

**Model Storage:**

```yaml
rasa:
  settings:
    endpoints:
      models:
        url: http://my-server.com/models/default_core@latest
        wait_time_between_pulls: 10
```

**Tracker Store (Redis example):**

```yaml
rasa:
  settings:
    endpoints:
      tracker_store:
        type: redis
        url: <host of the redis instance>
        port: 6379
        db: 0
        password: <password>
        use_ssl: false
```

**Event Broker (Kafka example):**

```yaml
rasa:
  settings:
    endpoints:
      event_broker:
        type: kafka
        url: localhost:9095
        sasl_mechanism: SCRAM-SHA-512
        security_protocol: SASL_PLAINTEXT
        sasl_username: testuser
        sasl_password: testpass123
        partition_by_sender: true
        client_id: rasa-broker
```

**Model Groups:**

```yaml
rasa:
  settings:
    endpoints:
      model_groups:
        - id: openai-gpt-4o
          models:
            - provider: openai
              model: gpt-4o-2024-11-20
              request_timeout: 7
              max_tokens: 256
```

See the [Rasa endpoints documentation](https://rasa.com/docs/pro/build/configuring-assistant#endpoints) for complete endpoint configuration options.

## Values

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| actionServer.additionalContainers | list | actionServer.additionalContainers allows to specify additional containers for the Action Server Deployment | `[]` |
| actionServer.additionalEnv | list | actionServer.additionalEnv adds additional environment variables | `[]` |
| actionServer.affinity | object | actionServer.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| actionServer.args | list | actionServer.args overrides the default arguments for the container | `[]` |
| actionServer.autoscaling.enabled | bool | autoscaling.enabled specifies whether autoscaling should be enabled | `false` |
| actionServer.autoscaling.maxReplicas | int | autoscaling.maxReplicas specifies the maximum number of replicas | `100` |
| actionServer.autoscaling.minReplicas | int | autoscaling.minReplicas specifies the minimum number of replicas | `1` |
| actionServer.autoscaling.targetCPUUtilizationPercentage | int | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage | `80` |
| actionServer.command | list | actionServer.command overrides the default command for the container | `[]` |
| actionServer.containerSecurityContext | object | actionServer.containerSecurityContext defines security context that allows you to overwrite the container-level security context | `{"enabled":true}` |
| actionServer.enabled | bool | actionServer.enabled enables Action Server deployment | `false` |
| actionServer.envFrom | list | actionServer.envFrom is used to add environment variables from ConfigMap or Secret | `[]` |
| actionServer.image.pullPolicy | string | image.pullPolicy specifies image pull policy | `"IfNotPresent"` |
| actionServer.image.repository | string | image.repository specifies image repository | `"rasa/rasa-sdk"` |
| actionServer.image.tag | string | image.tag specifies image tag | `"3.15.0-latest"` |
| actionServer.ingress.annotations | object | ingress.annotations defines annotations to add to the ingress | `{}` |
| actionServer.ingress.className | string | ingress.className specifies the ingress className to be used | `""` |
| actionServer.ingress.enabled | bool | ingress.enabled specifies whether an ingress service should be created | `false` |
| actionServer.ingress.hosts | list | ingress.hosts specifies the hosts for this ingress | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}]` |
| actionServer.ingress.labels | object | ingress.lables defines labels to add to the ingress | `{}` |
| actionServer.ingress.tls | list | ingress.tls spefices the TLS configuration for ingress | `[]` |
| actionServer.initContainers | list | actionServer.initContainers allows to specify init containers for the Action Server deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ | `[]` |
| actionServer.livenessProbe.enabled | bool | livenessProbe.enabled is used to enable or disable liveness probe | `true` |
| actionServer.livenessProbe.failureThreshold | int | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| actionServer.livenessProbe.httpGet | object | livenessProbe.httpGet is used to define HTTP request | `{"path":"/health","port":5055,"scheme":"HTTP"}` |
| actionServer.livenessProbe.initialDelaySeconds | int | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| actionServer.livenessProbe.periodSeconds | int | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| actionServer.livenessProbe.successThreshold | int | livenessProbe.successThreshold defines how often (in seconds) to perform the probe | `1` |
| actionServer.livenessProbe.terminationGracePeriodSeconds | int | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container | `30` |
| actionServer.livenessProbe.timeoutSeconds | int | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| actionServer.nodeSelector | object | actionServer.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| actionServer.podAnnotations | object | actionServer.podAnnotations defines annotations to add to the pod | `{}` |
| actionServer.podSecurityContext | object | actionServer.podSecurityContext defines pod security context | `{"enabled":true}` |
| actionServer.readinessProbe.enabled | bool | readinessProbe.enabled is used to enable or disable readinessProbe | `true` |
| actionServer.readinessProbe.failureThreshold | int | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| actionServer.readinessProbe.httpGet | object | readinessProbe.httpGet is used to define HTTP request | `{"path":"/health","port":5055,"scheme":"HTTP"}` |
| actionServer.readinessProbe.initialDelaySeconds | int | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| actionServer.readinessProbe.periodSeconds | int | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| actionServer.readinessProbe.successThreshold | int | readinessProbe.successThreshold defines how often (in seconds) to perform the probe | `1` |
| actionServer.readinessProbe.timeoutSeconds | int | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| actionServer.replicaCount | int | actionServer.replicaCount specifies number of replicas | `1` |
| actionServer.resources | object | actionServer.resources specifies the resources limits and requests | `{}` |
| actionServer.service | object | actionServer.service define service for Action Server | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":5055,"targetPort":5055,"type":"ClusterIP"}` |
| actionServer.service.annotations | object | service.annotations defines annotations to add to the service | `{}` |
| actionServer.service.externalTrafficPolicy | string | service.externalTrafficPolicy enables client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip | `"Cluster"` |
| actionServer.service.loadBalancerIP | string | service.loadBalancerIP exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer | `nil` |
| actionServer.service.nodePort | string | service.nodePort is used to specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport | `nil` |
| actionServer.service.port | int | service.port is used to specify service port | `5055` |
| actionServer.service.targetPort | int | service.targetPort is ued to specify service target port | `5055` |
| actionServer.service.type | string | service.type is used to specify service type | `"ClusterIP"` |
| actionServer.serviceAccount | object | actionServer.serviceAccount defines service account | `{"annotations":{},"create":true,"name":""}` |
| actionServer.serviceAccount.annotations | object | serviceAccount.annotations defines annotations to add to the service account | `{}` |
| actionServer.serviceAccount.create | bool | serviceAccount.create specifies whether a service account should be created | `true` |
| actionServer.serviceAccount.name | string | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""` |
| actionServer.settings.port | int | settings.port defines port on which Action Server runs | `5055` |
| actionServer.settings.scheme | string | settings.scheme defines sheme by which the service are accessible | `"http"` |
| actionServer.strategy | object | actionServer.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy | `{}` |
| actionServer.tolerations | list | actionServer.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| actionServer.volumeMounts | list | actionServer.volumeMounts specifies additional volumes to mount in the Action Server container | `[]` |
| actionServer.volumes | list | actionServer.volumes specify additional volumes to mount in the Action Server container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ | `[]` |
| deploymentAnnotations | object | deploymentAnnotations defines annotations to add to all Rasa deployments | `{}` |
| deploymentLabels | object | deploymentLabels defines labels to add to all Rasa deployment | `{}` |
| dnsConfig | object | dnsConfig specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config | `{}` |
| dnsPolicy | string | dnsPolicy specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy | `""` |
| duckling.additionalContainers | list | duckling.additionalContainers allows to specify additional containers for the Duckling Deployment | `[]` |
| duckling.additionalEnv | list | duckling.additionalEnv adds additional environment variables | `[]` |
| duckling.affinity | object | duckling.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| duckling.args | list | duckling.args overrides the default arguments for the container | `[]` |
| duckling.autoscaling.enabled | bool | autoscaling.enabled specifies whether autoscaling should be enabled | `false` |
| duckling.autoscaling.maxReplicas | int | autoscaling.maxReplicas specifies the maximum number of replicas | `100` |
| duckling.autoscaling.minReplicas | int | autoscaling.minReplicas specifies the minimum number of replicas | `1` |
| duckling.autoscaling.targetCPUUtilizationPercentage | int | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage | `80` |
| duckling.command | list | duckling.command overrides the default command for the container | `[]` |
| duckling.containerSecurityContext | object | duckling.containerSecurityContext defines security context that allows you to overwrite the container-level security context | `{"enabled":true}` |
| duckling.enabled | bool | duckling.enabled enables Duckling deployment | `false` |
| duckling.envFrom | list | duckling.envFrom is used to add environment variables from ConfigMap or Secret | `[]` |
| duckling.image.pullPolicy | string | image.pullPolicy specifies image pull policy | `"IfNotPresent"` |
| duckling.image.repository | string | image.repository specifies image repository | `"rasa/duckling"` |
| duckling.image.tag | string | image.tag specifies image tag | `"0.2.0.2-r3"` |
| duckling.ingress.annotations | object | ingress.annotations defines annotations to add to the ingress | `{}` |
| duckling.ingress.className | string | ingress.className specifies the ingress className to be used | `""` |
| duckling.ingress.enabled | bool | ingress.enabled specifies whether an ingress service should be created | `false` |
| duckling.ingress.hosts | list | ingress.hosts specifies the hosts for this ingress | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"Prefix"}]}]` |
| duckling.ingress.labels | object | ingress.lables defines labels to add to the ingress | `{}` |
| duckling.ingress.tls | list | ingress.tls spefices the TLS configuration for ingress | `[]` |
| duckling.initContainers | list | duckling.initContainers allows to specify init containers for the Duckling deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ | `[]` |
| duckling.livenessProbe.enabled | bool | livenessProbe.enabled is used to enable or disable liveness probe | `true` |
| duckling.livenessProbe.failureThreshold | int | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| duckling.livenessProbe.httpGet | object | livenessProbe.httpGet is used to define HTTP request | `{"path":"/","port":8000,"scheme":"HTTP"}` |
| duckling.livenessProbe.initialDelaySeconds | int | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| duckling.livenessProbe.periodSeconds | int | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| duckling.livenessProbe.successThreshold | int | livenessProbe.successThreshold defines how often (in seconds) to perform the probe | `1` |
| duckling.livenessProbe.terminationGracePeriodSeconds | int | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container | `30` |
| duckling.livenessProbe.timeoutSeconds | int | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| duckling.nodeSelector | object | duckling.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| duckling.podAnnotations | object | duckling.podAnnotations defines annotations to add to the pod | `{}` |
| duckling.podSecurityContext | object | duckling.podSecurityContext defines pod security context | `{"enabled":true}` |
| duckling.readinessProbe.enabled | bool | readinessProbe.enabled is used to enable or disable readinessProbe | `true` |
| duckling.readinessProbe.failureThreshold | int | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| duckling.readinessProbe.httpGet | object | readinessProbe.httpGet is used to define HTTP request | `{"path":"/","port":8000,"scheme":"HTTP"}` |
| duckling.readinessProbe.initialDelaySeconds | int | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| duckling.readinessProbe.periodSeconds | int | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| duckling.readinessProbe.successThreshold | int | readinessProbe.successThreshold defines how often (in seconds) to perform the probe | `1` |
| duckling.readinessProbe.timeoutSeconds | int | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| duckling.replicaCount | int | duckling.replicaCount specifies number of replicas | `1` |
| duckling.resources | object | duckling.resources specifies the resources limits and requests | `{}` |
| duckling.service | object | duckling.service define service for Duckling | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":8000,"targetPort":8000,"type":"ClusterIP"}` |
| duckling.service.annotations | object | service.annotations defines annotations to add to the service | `{}` |
| duckling.service.externalTrafficPolicy | string | service.externalTrafficPolicy enables client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip | `"Cluster"` |
| duckling.service.loadBalancerIP | string | service.loadBalancerIP exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer | `nil` |
| duckling.service.nodePort | string | service.nodePort is used to specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport | `nil` |
| duckling.service.port | int | service.port is used to specify service port | `8000` |
| duckling.service.targetPort | int | service.targetPort is ued to specify service target port | `8000` |
| duckling.service.type | string | service.type is used to specify service type | `"ClusterIP"` |
| duckling.serviceAccount | object | duckling.serviceAccount defines service account | `{"annotations":{},"create":true,"name":""}` |
| duckling.serviceAccount.annotations | object | serviceAccount.annotations defines annotations to add to the service account | `{}` |
| duckling.serviceAccount.create | bool | serviceAccount.create specifies whether a service account should be created | `true` |
| duckling.serviceAccount.name | string | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""` |
| duckling.settings.port | int | settings.port defines port on which Duckling runs | `8000` |
| duckling.settings.scheme | string | settings.scheme defines sheme by which the service are accessible | `"http"` |
| duckling.strategy | object | duckling.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy | `{}` |
| duckling.tolerations | list | duckling.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| duckling.volumeMounts | list | duckling.volumeMounts specifies additional volumes to mount in the Duckling container | `[]` |
| duckling.volumes | list | duckling.volumes specify additional volumes to mount in the Duckling container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ | `[]` |
| fullnameOverride | string | fullnameOverride overrides the full qualified app name | `""` |
| global.additionalDeploymentLabels | object | global.additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ | `{}` |
| global.ingressHost | string |  | `nil` |
| hostAliases | list | hostAliases specifies pod-level override of hostname resolution when DNS and other options are not applicable | `[]` |
| hostNetwork | bool | hostNetwork controls whether the pod may use the node network namespace | `false` |
| imagePullSecrets | list | imagePullSecrets is used for private repository pull secrets | `[]` |
| nameOverride | string | nameOverride overrides name of the app | `""` |
| networkPolicy.denyAll | bool | Specifies whether to apply denyAll network policy | `false` |
| networkPolicy.enabled | bool | Specifies whether to enable network policies | `false` |
| networkPolicy.nodeCIDR | list | Allow for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes | `[]` |
| podLabels | object | podLabels defines labels to add to all Rasa pod(s) | `{}` |
| rasa.additionalArgs | list | rasa.additionalArgs adds additional arguments to the default args | `[]` |
| rasa.additionalContainers | list | rasa.additionalContainers allows to specify additional containers for the Rasa Deployment | `[]` |
| rasa.additionalEnv | list | rasa.additionalEnv adds additional environment variables | `[]` |
| rasa.affinity | object | rasa.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| rasa.args | list | rasa.args overrides the default arguments for the container | `[]` |
| rasa.autoscaling.enabled | bool | autoscaling.enabled specifies whether autoscaling should be enabled | `false` |
| rasa.autoscaling.maxReplicas | int | autoscaling.maxReplicas specifies the maximum number of replicas | `100` |
| rasa.autoscaling.minReplicas | int | autoscaling.minReplicas specifies the minimum number of replicas | `1` |
| rasa.autoscaling.targetCPUUtilizationPercentage | int | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage | `80` |
| rasa.command | list | rasa.command overrides the default command for the container | `[]` |
| rasa.containerSecurityContext | object | rasa.containerSecurityContext defines security context that allows you to overwrite the container-level security context | `{"enabled":true}` |
| rasa.enabled | bool | rasa.enabled enables Rasa Plus deployment Disable this if you want to deploy ONLY Rasa Pro Services | `true` |
| rasa.envFrom | list | rasa.envFrom is used to add environment variables from ConfigMap or Secret | `[]` |
| rasa.image.pullPolicy | string | image.pullPolicy specifies image pull policy | `"IfNotPresent"` |
| rasa.image.repository | string | image.repository specifies image repository | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` |
| rasa.image.tag | string | image.tag specifies image tag | `"3.15.3-latest"` |
| rasa.ingress.annotations | object | ingress.annotations defines annotations to add to the ingress | `{}` |
| rasa.ingress.className | string | ingress.className specifies the ingress className to be used | `""` |
| rasa.ingress.enabled | bool | ingress.enabled specifies whether an ingress service should be created | `false` |
| rasa.ingress.hosts | list | ingress.hosts specifies the hosts for this ingress | `[{"extraPaths":[],"host":"INGRESS.HOST.NAME","paths":[{"path":"/api","pathType":"Prefix"}]}]` |
| rasa.ingress.labels | object | ingress.lables defines labels to add to the ingress | `{}` |
| rasa.ingress.tls | list | ingress.tls spefices the TLS configuration for ingress | `[]` |
| rasa.initContainers | list | rasa.initContainers allows to specify init containers for the Rasa deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ # <PATH_TO_INITIAL_MODEL> has to be a URL (without auth) that points to a tar.gz file | `[]` |
| rasa.livenessProbe.enabled | bool | livenessProbe.enabled is used to enable or disable liveness probe | `true` |
| rasa.livenessProbe.failureThreshold | int | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| rasa.livenessProbe.httpGet | object | livenessProbe.httpGet is used to define HTTP request | `{"path":"/","port":5005,"scheme":"HTTP"}` |
| rasa.livenessProbe.initialDelaySeconds | int | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| rasa.livenessProbe.periodSeconds | int | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| rasa.livenessProbe.successThreshold | int | livenessProbe.successThreshold defines how often (in seconds) to perform the probe | `1` |
| rasa.livenessProbe.terminationGracePeriodSeconds | int | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container | `30` |
| rasa.livenessProbe.timeoutSeconds | int | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| rasa.nodeSelector | object | rasa.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| rasa.overrideEnv | list | rasa.overrideEnv overrides all default environment variables | `[]` |
| rasa.persistence.create | bool |  | `false` |
| rasa.persistence.hostPath.enabled | bool |  | `false` |
| rasa.persistence.storageCapacity | string |  | `"1Gi"` |
| rasa.persistence.storageClassName | string |  | `nil` |
| rasa.persistence.storageRequests | string |  | `"1Gi"` |
| rasa.podAnnotations | object | rasa.podAnnotations defines annotations to add to the pod | `{}` |
| rasa.podSecurityContext | object | rasa.podSecurityContext defines pod security context | `{"enabled":true}` |
| rasa.readinessProbe.enabled | bool | readinessProbe.enabled is used to enable or disable readinessProbe | `true` |
| rasa.readinessProbe.failureThreshold | int | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| rasa.readinessProbe.httpGet | object | readinessProbe.httpGet is used to define HTTP request | `{"path":"/","port":5005,"scheme":"HTTP"}` |
| rasa.readinessProbe.initialDelaySeconds | int | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| rasa.readinessProbe.periodSeconds | int | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| rasa.readinessProbe.successThreshold | int | readinessProbe.successThreshold defines how often (in seconds) to perform the probe | `1` |
| rasa.readinessProbe.timeoutSeconds | int | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| rasa.replicaCount | int | rasa.replicaCount specifies number of replicas | `1` |
| rasa.resources | object | rasa.resources specifies the resources limits and requests | `{}` |
| rasa.service | object | rasa.service define service for Rasa OSS/Plus | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":5005,"targetPort":5005,"type":"ClusterIP"}` |
| rasa.service.annotations | object | service.annotations defines annotations to add to the service | `{}` |
| rasa.service.externalTrafficPolicy | string | service.externalTrafficPolicy enables client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip | `"Cluster"` |
| rasa.service.loadBalancerIP | string | service.loadBalancerIP exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer | `nil` |
| rasa.service.nodePort | string | service.nodePort is used to specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport | `nil` |
| rasa.service.port | int | service.port is used to specify service port | `5005` |
| rasa.service.targetPort | int | service.targetPort is ued to specify service target port | `5005` |
| rasa.service.type | string | service.type is used to specify service type | `"ClusterIP"` |
| rasa.serviceAccount | object | rasa.serviceAccount defines service account | `{"annotations":{},"create":true,"name":""}` |
| rasa.serviceAccount.annotations | object | serviceAccount.annotations defines annotations to add to the service account | `{}` |
| rasa.serviceAccount.create | bool | serviceAccount.create specifies whether a service account should be created | `true` |
| rasa.serviceAccount.name | string | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""` |
| rasa.settings.authToken | object | settings.authToken is token Rasa accepts as authentication token from other Rasa services | `{"secretKey":"authToken","secretName":"rasa-secrets"}` |
| rasa.settings.cors | string | settings.cors is CORS for the passed origin. Default is * to allow all origins | `"*"` |
| rasa.settings.credentials | object | settings.credentials enables credentials configuration for channel connectors # See: https://rasa.com/docs/reference/channels/messaging-and-voice-channels | `{}` |
| rasa.settings.debugMode | bool | settings.debugMode enables debug mode | `false` |
| rasa.settings.ducklingHttpUrl | string | settings.ducklingHttpUrl is HTTP URL to the duckling service | `nil` |
| rasa.settings.enableApi | bool | settings.enableApi start the web server API in addition to the input channel Rasa API supports two authentication methods, Token based Auth or JWT Enter details in token or (jwtSecret, jwtMethod) to enable either of them | `true` |
| rasa.settings.endpoints | object | settings.endpoints enables endpoints configuration for the Rasa deployment. See: https://rasa.com/docs/pro/build/configuring-assistant#endpoints | `{}` |
| rasa.settings.environment | string | settings.environment: development or production | `"development"` |
| rasa.settings.jwtMethod | string | settings.jwtMethod is JWT algorithm to be used | `"HS256"` |
| rasa.settings.jwtSecret | object | settings.jwtSecret is JWT token Rasa accepts as authentication token from other Rasa services | `{"secretKey":"jwtSecret","secretName":"rasa-secrets"}` |
| rasa.settings.logging.logLevel | string | logging.logLevel is Rasa Log Level | `"info"` |
| rasa.settings.mountDefaultConfigmap | bool | settings.mountVolumes is a flag to disable mounting of credentials.yml and endpoints.yml to the Rasa Pro deployment. In this case it is expected that the credentials and endpoints are mounted to the /.config directory or baked into the image. | `true` |
| rasa.settings.mountModelsVolume | bool | settings.mountModelsVolume is a flag to disable mounting of models volume to the Rasa Pro deployment. In this case it is expected that the models are mounted to the /app/models directory or baked into the image. | `true` |
| rasa.settings.port | int | settings.port defines port on which Rasa runs | `5005` |
| rasa.settings.scheme | string | settings.scheme defines scheme by which the service are accessible | `"http"` |
| rasa.settings.telemetry.debug | bool | telemetry.debug prints telemetry data to stdout | `false` |
| rasa.settings.telemetry.enabled | bool | telemetry.enabled allow Rasa to collect anonymous usage details | `true` |
| rasa.settings.useDefaultArgs | bool | settings.useDefaultArgs is to disable default startup args to be able to be used by Studio. There is no need to ever disable this in Rasa Pro case. | `true` |
| rasa.strategy | object | rasa.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy | `{}` |
| rasa.tolerations | list | rasa.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| rasa.volumeMounts | list | rasa.volumeMounts specifies additional volumes to mount in the Rasa container | `[]` |
| rasa.volumes | list | rasa.volumes specify additional volumes to mount in the Rasa container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ | `[]` |
| rasaProLicense | object | rasaProLicense is license key for Rasa Pro Services. | `{"secretKey":"rasaProLicense","secretName":"rasa-secrets"}` |
| rasaProServices.additionalContainers | list | rasaProServices.additionalContainers allows to specify additional containers for the Rasa Pro Services Deployment | `[]` |
| rasaProServices.additionalEnv | list | rasaProServices.additionalEnv allows you to specify additional environment variables for the Rasa Pro Services container These are rendered as-is using toYaml, providing maximum flexibility for environment variable configuration Example:   additionalEnv:     - name: MY_CUSTOM_VAR       value: "some-value"     - name: SECRET_VAR       valueFrom:         secretKeyRef:           name: my-secret           key: secret-key     - name: CONFIGMAP_VAR       valueFrom:         configMapKeyRef:           name: my-configmap           key: config-key | `[]` |
| rasaProServices.affinity | object | rasaProServices.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| rasaProServices.autoscaling.enabled | bool | autoscaling.enabled specifies whether autoscaling should be enabled | `false` |
| rasaProServices.autoscaling.maxReplicas | int | autoscaling.maxReplicas specifies the maximum number of replicas | `100` |
| rasaProServices.autoscaling.minReplicas | int | autoscaling.minReplicas specifies the minimum number of replicas | `1` |
| rasaProServices.autoscaling.targetCPUUtilizationPercentage | int | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage | `80` |
| rasaProServices.containerSecurityContext | object | rasaProServices.containerSecurityContext defines security context that allows you to overwrite the container-level security context | `{"enabled":true}` |
| rasaProServices.database.databaseName | string | database.databaseName specifies the database name for the data lake to store analytics data in. Required if enableAwsRdsIam is true. | `""` |
| rasaProServices.database.enableAwsRdsIam | bool | database.enableAwsRdsIam specifies whether to use AWS RDS IAM authentication for the Rasa Pro Services container. | `false` |
| rasaProServices.database.hostname | string | database.hostname specifies the hostname of the data lake to store analytics data in. Required if enableAwsRdsIam is true. | `""` |
| rasaProServices.database.port | string | database.port specifies the port for the data lake to store analytics data in. Required if enableAwsRdsIam is true. | `"5432"` |
| rasaProServices.database.sslCaLocation | string | database.sslCaLocation specifies the SSL CA location for the data lake to store analytics data in. Required if sslMode is verify-full. | `""` |
| rasaProServices.database.sslMode | string | database.sslMode specifies the SSL mode for the data lake to store analytics data in. Required if enableAwsRdsIam is true. | `""` |
| rasaProServices.database.url | string | database.url specifies the URL of the data lake to store analytics data in. Use `hostname` if you use IAM authentication. | `""` |
| rasaProServices.database.username | string | database.username specifies the username for the data lake to store analytics data in. Required if enableAwsRdsIam is true. | `""` |
| rasaProServices.enabled | bool | rasaProServices.enabled enables Rasa Pro Services deployment | `true` |
| rasaProServices.envFrom | list | rasaProServices.envFrom is used to add environment variables from ConfigMap or Secret | `[]` |
| rasaProServices.image.pullPolicy | string | image.pullPolicy specifies image pull policy | `"IfNotPresent"` |
| rasaProServices.image.repository | string | image.repository specifies image repository | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro-services"` |
| rasaProServices.image.tag | string | Specifies image tag image.tag specifies image tag | `"3.7.0-latest"` |
| rasaProServices.imagePullSecrets | list | imagePullSecrets is used for private repository pull secrets # If this is not set, global `imagePullSecrets` will be applied. If both are set, this takes priority. | `[]` |
| rasaProServices.kafka.brokerAddress | string | kafka.brokerAddress specifies the broker address for the Rasa Pro Services container. Required if enableAwsMskIam is true. | `""` |
| rasaProServices.kafka.consumerId | string | kafka.consumerId specifies the consumer ID for the Rasa Pro Services container. | `"rasa-analytics-group"` |
| rasaProServices.kafka.dlqTopic | string | kafka.dlqTopic specifies the DLQ topic fused to publish events that resulted in a processing failure. | `"rasa-analytics-dlq"` |
| rasaProServices.kafka.enableAwsMskIam | bool | kafka.enableAwsMskIam specifies whether to use AWS MSK IAM authentication for the Rasa Pro Services container. | `false` |
| rasaProServices.kafka.saslMechanism | string | kafka.saslMechanism specifies the SASL mechanism for the Rasa Pro Services container. Leave empty if you are using SSL. | `""` |
| rasaProServices.kafka.saslPassword | object | kafka.saslPassword specifies the SASL password for the Rasa Pro Services container. Do not set if enableAwsMskIam is true. | `{"secretKey":"kafkaSslPassword","secretName":"rasa-secrets"}` |
| rasaProServices.kafka.saslUsername | string | kafka.saslUsername specifies the SASL username for the Rasa Pro Services container. Do not set if enableAwsMskIam is true. | `""` |
| rasaProServices.kafka.securityProtocol | string | kafka.securityProtocol specifies the security protocol for the Rasa Pro Services container. Supported mechanisms are PLAINTEXT, SASL_PLAINTEXT, SASL_SSL and SSL | `""` |
| rasaProServices.kafka.sslCaLocation | string | kafka.sslCaLocation specifies the SSL CA location for the Rasa Pro Services container. | `""` |
| rasaProServices.kafka.sslCertFileLocation | string | kafka.sslCertFileLocation specifies the filepath for SSL client Certificate that will be used to connect with Kafka. Required if securityProtocol is SSL. | `""` |
| rasaProServices.kafka.sslKeyFileLocation | string | kafka.sslKeyFileLocation specifies the filepath for SSL Keyfile that will be used to connect with Kafka. Required if securityProtocol is SSL. | `""` |
| rasaProServices.kafka.topic | string | kafka.topic specifies the topic for the Rasa Pro Services container. | `"rasa-core-events"` |
| rasaProServices.livenessProbe.enabled | bool | livenessProbe.enabled is used to enable or disable liveness probe | `true` |
| rasaProServices.livenessProbe.failureThreshold | int | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| rasaProServices.livenessProbe.httpGet | object | livenessProbe.httpGet is used to define HTTP request | `{"path":"/healthcheck","port":8732,"scheme":"HTTP"}` |
| rasaProServices.livenessProbe.initialDelaySeconds | int | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| rasaProServices.livenessProbe.periodSeconds | int | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| rasaProServices.livenessProbe.successThreshold | int | livenessProbe.successThreshold defines how often (in seconds) to perform the probe | `1` |
| rasaProServices.livenessProbe.terminationGracePeriodSeconds | int | readinessProbe.terminationGracePeriodSeconds configures a grace period to wait between triggering a shut down of the failed container | `30` |
| rasaProServices.livenessProbe.timeoutSeconds | int | livenessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| rasaProServices.loggingLevel | string | rasaProServices.loggingLevel specifies the logging level for the Rasa Pro Services container. Valid levels are DEBUG, INFO, WARNING, ERROR, CRITICAL. | `"INFO"` |
| rasaProServices.nodeSelector | object | rasaProServices.nodeSelector allows the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ | `{}` |
| rasaProServices.podAnnotations | object | rasaProServices.podAnnotations defines annotations to add to the pod | `{}` |
| rasaProServices.podSecurityContext | object | rasaProServices.podSecurityContext defines pod security context | `{"enabled":true}` |
| rasaProServices.readinessProbe.enabled | bool | readinessProbe.enabled is used to enable or disable readinessProbe | `true` |
| rasaProServices.readinessProbe.failureThreshold | int | readinessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| rasaProServices.readinessProbe.httpGet | object | readinessProbe.httpGet is used to define HTTP request | `{"path":"/healthcheck","port":8732,"scheme":"HTTP"}` |
| rasaProServices.readinessProbe.initialDelaySeconds | int | readinessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| rasaProServices.readinessProbe.periodSeconds | int | readinessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| rasaProServices.readinessProbe.successThreshold | int | readinessProbe.successThreshold defines how often (in seconds) to perform the probe | `1` |
| rasaProServices.readinessProbe.timeoutSeconds | int | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| rasaProServices.replicaCount | int | rasaProServices.replicaCount specifies number of replicas | `1` |
| rasaProServices.resources | object | rasaProServices.resources specifies the resources limits and requests | `{}` |
| rasaProServices.service | object | rasaProServices.service define service for Rasa OSS/Plus | `{"annotations":{},"port":8732,"targetPort":8732,"type":"ClusterIP"}` |
| rasaProServices.service.annotations | object | service.annotations defines annotations to add to the service | `{}` |
| rasaProServices.service.port | int | service.port is used to specify service port | `8732` |
| rasaProServices.service.targetPort | int | service.targetPort is ued to specify service target port | `8732` |
| rasaProServices.service.type | string | service.type is used to specify service type | `"ClusterIP"` |
| rasaProServices.serviceAccount | object | rasaProServices.serviceAccount defines service account | `{"annotations":{},"create":true,"name":""}` |
| rasaProServices.serviceAccount.annotations | object | serviceAccount.annotations defines annotations to add to the service account | `{}` |
| rasaProServices.serviceAccount.create | bool | serviceAccount.create specifies whether a service account should be created | `true` |
| rasaProServices.serviceAccount.name | string | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""` |
| rasaProServices.strategy | object | rasaProServices.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy | `{}` |
| rasaProServices.tolerations | list | rasaProServices.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| rasaProServices.useCloudProviderIam.enabled | bool | useCloudProviderIam.enabled specifies whether to use cloud provider IAM for the Rasa Pro Services container. | `false` |
| rasaProServices.useCloudProviderIam.provider | string | useCloudProviderIam.provider specifies the cloud provider for the Rasa Pro Services container. Supported value is aws | `"aws"` |
| rasaProServices.useCloudProviderIam.region | string | useCloudProviderIam.region specifies the region for IAM authentication. Required if IAM_CLOUD_PROVIDER is set to aws. | `"us-east-1"` |
| rasaProServices.volumeMounts | list | rasaProServices.volumeMounts specifies additional volumes to mount in the Rasa Pro Services container | `[]` |
| rasaProServices.volumes | list | rasaProServices.volumes specify additional volumes for the Rasa Pro Services container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ | `[]` |
