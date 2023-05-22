# studio

This chart bootstraps Studio deployment on a Kubernetes cluster using the Helm package manager.

![Version: 0.1.6](https://img.shields.io/badge/Version-0.1.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm pull oci://registry-1.docker.io/helm-charts/studio --version VERSION
$ helm install my-release oci://registry-1.docker.io/helm-charts/studio --version VERSION
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
$ helm pull oci://registry-1.docker.io/helm-charts/studio --version VERSION
```

## Values

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backend.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| backend.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Specifies the HPA settings |
| backend.autoscaling.enabled | bool | `false` | Specifies whether autoscaling should be enabled |
| backend.autoscaling.maxReplicas | int | `100` | Specifies the maximum number of replicas |
| backend.autoscaling.minReplicas | int | `1` | Specifies the minimum number of replicas |
| backend.autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the target CPU/Memory utilization percentage |
| backend.environmentVariables | list | `[{"name":"DATABASE_URL","value":""},{"name":"SECURITY_PROTOCOL","value":"SASL_SSL"},{"name":"SASL_MECHANISM","value":"SCRAM-SHA-256"},{"name":"SASL_USERNAME","value":""},{"name":"SASL_PASSWORD","value":""},{"name":"KAFKA_BROKER_ADDRESS","value":""},{"name":"KAFKA_TOPIC","value":""},{"name":"KAFKA_DLQ_TOPIC","value":""},{"name":"KAFKA_CLIENT_ID","value":""},{"name":"GROUP_ID","value":""},{"name":"KEYCLOAK_URL","value":""},{"name":"KEYCLOAK_REALM","value":""},{"name":"KEYCLOAK_API_USERNAME","value":""},{"name":"KEYCLOAK_API_PASSWORD","value":""},{"name":"KEYCLOAK_API_GRANTTYPE","value":""}]` | Define environment variables for deployment |
| backend.image | object | `{"pullPolicy":"IfNotPresent","repository":null,"tag":""}` | Define image settings |
| backend.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| backend.image.repository | string | `nil` | Specifies image repository |
| backend.image.tag | string | `""` | Specifies image tag # Overrides the image tag whose default is the chart appVersion. |
| backend.ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"ImplementationSpecific"}]}],"tls":[]}` | Configure the ingress resource that allows you to access the deployment installation. Set up the URL. # ref: http://kubernetes.io/docs/user-guide/ingress/ |
| backend.ingress.annotations | object | `{}` | Annotations to add to the ingress |
| backend.ingress.className | string | `""` | Specifies the ingress className to be used |
| backend.ingress.enabled | bool | `false` | Specifies whether an ingress service should be created |
| backend.ingress.hosts | list | `[{"extraPaths":[],"host":"chart-example.local","paths":[{"path":"/api","pathType":"ImplementationSpecific"}]}]` | Specifies the hosts for this ingress |
| backend.ingress.tls | list | `[]` | Spefices the TLS configuration for ingress |
| backend.livenessProbe | object | `{"failureThreshold":6,"httpGet":{"path":"/","port":"http","scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| backend.migration | object | `{"database_url":null,"enable":false,"image":{"repository":null,"tag":null}}` | Define Studio Database Migration job settings |
| backend.migration.database_url | string | `nil` | Specifies the database URL where migration should be done |
| backend.migration.enable | bool | `false` | Specifies whether a database migration job should be created |
| backend.migration.image | object | `{"repository":null,"tag":null}` | Specifies which image database migration job should use |
| backend.migration.image.repository | string | `nil` | Specifies the repository of the image |
| backend.migration.image.tag | string | `nil` | Specifies the tag of the image |
| backend.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| backend.podAnnotations | object | `{}` | Annotations to add to the pod |
| backend.podSecurityContext | object | `{}` | Define pod security context |
| backend.readinessProbe | object | `{"failureThreshold":6,"httpGet":{"path":"/","port":"http","scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| backend.replicaCount | int | `1` | Specifies number of replicas |
| backend.resources | object | `{}` | Specifies the resources limits and requests |
| backend.securityContext | object | `{}` | Define security context that allows you to overwrite the pod-level security context |
| backend.service | object | `{"port":4000,"type":"ClusterIP"}` | Define service |
| backend.service.port | int | `4000` | Specify service port |
| backend.service.type | string | `"ClusterIP"` | Specify service type |
| backend.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Define service account |
| backend.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| backend.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| backend.serviceAccount.name | string | `""` | The name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| backend.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| dnsConfig | object | `{}` | Specifies Pod's DNS condig # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config |
| dnsPolicy | string | `""` | Specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| eventIngestion.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| eventIngestion.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Specifies the HPA settings |
| eventIngestion.autoscaling.enabled | bool | `false` | Specifies whether autoscaling should be enabled |
| eventIngestion.autoscaling.maxReplicas | int | `100` | Specifies the maximum number of replicas |
| eventIngestion.autoscaling.minReplicas | int | `1` | Specifies the minimum number of replicas |
| eventIngestion.autoscaling.targetCPUUtilizationPercentage | int | `80` | Specifies the target CPU/Memory utilization percentage |
| eventIngestion.environmentVariables | list | `[{"name":"DATABASE_URL","value":""},{"name":"SECURITY_PROTOCOL","value":"SASL_SSL"},{"name":"SASL_MECHANISM","value":"SCRAM-SHA-256"},{"name":"SASL_USERNAME","value":""},{"name":"SASL_PASSWORD","value":""},{"name":"KAFKA_BROKER_ADDRESS","value":""},{"name":"KAFKA_TOPIC","value":""},{"name":"KAFKA_DLQ_TOPIC","value":""},{"name":"KAFKA_CLIENT_ID","value":""},{"name":"GROUP_ID","value":""}]` | Define environment variables for deployment |
| eventIngestion.image | object | `{"pullPolicy":"IfNotPresent","repository":null,"tag":""}` | Define image settings |
| eventIngestion.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| eventIngestion.image.repository | string | `nil` | Specifies image repository |
| eventIngestion.image.tag | string | `""` | Specifies image tag # Overrides the image tag whose default is the chart appVersion. |
| eventIngestion.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| eventIngestion.podAnnotations | object | `{}` | Annotations to add to the pod |
| eventIngestion.podSecurityContext | object | `{}` | Define pod security context |
| eventIngestion.replicaCount | int | `1` | Specifies number of replicas |
| eventIngestion.resources | object | `{}` | Specifies the resources limits and requests |
| eventIngestion.securityContext | object | `{}` | Define security context that allows you to overwrite the pod-level security context |
| eventIngestion.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Define service account |
| eventIngestion.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| eventIngestion.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| eventIngestion.serviceAccount.name | string | `""` | The name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| eventIngestion.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| fullnameOverride | string | `""` | Override the full qualified app name |
| global.additionalDeploymentLabels | object | `{}` | additionalDeploymentLabels can be used to map organizational structures onto system objects https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| hostNetwork | bool | `false` | Controls whether the pod may use the node network namespace |
| imagePullSecrets | list | `[]` | Repository pull secrets |
| keycloak.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| keycloak.image | object | `{"pullPolicy":"IfNotPresent","repository":null,"tag":""}` | Define image settings |
| keycloak.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| keycloak.image.repository | string | `nil` | Specifies image repository |
| keycloak.image.tag | string | `""` | Specifies image tag # Overrides the image tag whose default is the chart appVersion. |
| keycloak.livenessProbe | object | `{"failureThreshold":6,"httpGet":{"path":"/","port":"http","scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| keycloak.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| keycloak.podAnnotations | object | `{}` | Annotations to add to the pod |
| keycloak.podSecurityContext | object | `{}` | Define pod security context |
| keycloak.readinessProbe | object | `{"failureThreshold":6,"httpGet":{"path":"/","port":"http","scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| keycloak.replicaCount | int | `1` | Specifies number of replicas |
| keycloak.resources | object | `{}` | Specifies the resources limits and requests |
| keycloak.securityContext | object | `{}` | Define security context that allows you to overwrite the pod-level security context |
| keycloak.service | object | `{"port":8080,"type":"ClusterIP"}` | Define service |
| keycloak.service.port | int | `8080` | Specify service port |
| keycloak.service.type | string | `"ClusterIP"` | Specify service type |
| keycloak.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Define service account |
| keycloak.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| keycloak.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| keycloak.serviceAccount.name | string | `""` | The name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| keycloak.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| nameOverride | string | `""` | Override name of app |
| networkPolicy.denyAll | bool | `false` | Specifies whether to apply denyAll network policy |
| networkPolicy.enabled | bool | `false` | Specifies whether to enable network policies |
| networkPolicy.nodeCIDR | list | `[]` | Allow for traffic from a given CIDR - it's required in order to make kubelet able to run live and readiness probes |
| webClient.affinity | object | `{}` | Allow the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| webClient.image | object | `{"pullPolicy":"IfNotPresent","repository":null,"tag":""}` | Define image settings |
| webClient.image.pullPolicy | string | `"IfNotPresent"` | Specifies image pull policy |
| webClient.image.repository | string | `nil` | Specifies image repository |
| webClient.image.tag | string | `""` | Specifies image tag # Overrides the image tag whose default is the chart appVersion. |
| webClient.livenessProbe | object | `{"failureThreshold":6,"httpGet":{"path":"/","port":"http","scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default liveness probe settings |
| webClient.nodeSelector | object | `{}` | Allow the deployment to be scheduled on selected nodes # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector # Ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| webClient.podAnnotations | object | `{}` | Annotations to add to the pod |
| webClient.podSecurityContext | object | `{}` | Define pod security context |
| webClient.readinessProbe | object | `{"failureThreshold":6,"httpGet":{"path":"/","port":"http","scheme":"HTTP"},"initialDelaySeconds":15,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":5}` | Override default readiness probe settings |
| webClient.replicaCount | int | `1` | Specifies number of replicas |
| webClient.resources | object | `{}` | Specifies the resources limits and requests |
| webClient.securityContext | object | `{}` | Define security context that allows you to overwrite the pod-level security context |
| webClient.service | object | `{"port":80,"type":"ClusterIP"}` | Define service |
| webClient.service.port | int | `80` | Specify service port |
| webClient.service.type | string | `"ClusterIP"` | Specify service type |
| webClient.serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Define service account |
| webClient.serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| webClient.serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| webClient.serviceAccount.name | string | `""` | The name of the service account to use. # If not set and create is true, a name is generated using the fullname template |
| webClient.tolerations | list | `[]` | Tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
