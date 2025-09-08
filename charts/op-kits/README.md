# op-kits

Operator Kits Helm Chart

![Version: 0.1.0-rc.1g](https://img.shields.io/badge/Version-0.1.0--rc.1g-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- CloudNativePG operator installed (if not using dependency)
- Strimzi Kafka operator installed (if not using dependency)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/op-kits --version 0.1.0-rc.1g
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
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/op-kits --version 0.1.0-rc.1g
```

## Operator Dependencies

This chart can optionally install the required operators as dependencies:

### Installing with Operators

To install the chart with the operators included:

```console
$ helm install my-release . --set cloudnativepg.operator.enabled=true --set strimzi.operator.enabled=true
```

### Manual Operator Installation

If you prefer to install the operators manually:

1. **CloudNativePG Operator:**
   ```console
   $ helm repo add cnpg https://cloudnative-pg.github.io/charts
   $ helm install cnpg cnpg/cloudnative-pg
   ```

2. **Strimzi Kafka Operator:**
   ```console
   $ helm repo add strimzi https://strimzi.io/charts/
   $ helm install strimzi strimzi/strimzi-kafka-operator
   ```

## General Configuration

- **CloudNativePG**: Configure PostgreSQL clusters with customizable storage, instances, and monitoring
- **Strimzi Kafka**: Configure Kafka clusters with KRaft mode, node pools, topics, and users
- **Storage Classes**: Make sure to set the correct storage class names based on your cluster configuration
- **Resource Management**: Configure CPU, memory limits and requests for optimal performance

## Important Configuration Notes

### Storage Configuration

Both PostgreSQL and Kafka require persistent storage. Update the storage class names in your values:

```yaml
cloudnativepg:
  cluster:
    storage:
      storageClass: "your-storage-class"  # Update this

strimzi:
  nodePools:
    controllers:
      storage:
        class: "your-storage-class"  # Update this
    brokers:
      storage:
        volumes:
          - class: "your-storage-class"  # Update this
```

### Scaling Considerations

When scaling Kafka brokers, remember to adjust replication factors:

```yaml
strimzi:
  kafka:
    config:
      default.replication.factor: 3  # Match your broker count
      min.insync.replicas: 2
  topics:
    events:
      replicas: 3  # Match your broker count
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for all pods Example: affinity:   nodeAffinity:     requiredDuringSchedulingIgnoredDuringExecution:       nodeSelectorTerms:       - matchExpressions:         - key: kubernetes.io/os           operator: In           values:           - linux   podAntiAffinity:     preferredDuringSchedulingIgnoredDuringExecution:     - weight: 100       podAffinityTerm:         labelSelector:           matchExpressions:           - key: app.kubernetes.io/name             operator: In             values:             - op-kits         topologyKey: kubernetes.io/hostname |
| cloudnative-pg | object | `{}` |  |
| cloudnativepg.cluster.bootstrap.initdb.database | string | `"app"` | Database name to create during initialization |
| cloudnativepg.cluster.bootstrap.initdb.owner | string | `"appuser"` | Database owner/user to create during initialization |
| cloudnativepg.cluster.enableSuperuserAccess | bool | `true` | Enable superuser access (creates <cluster>-superuser secret) |
| cloudnativepg.cluster.imageName | string | `"ghcr.io/cloudnative-pg/postgresql:16"` | PostgreSQL container image to use |
| cloudnativepg.cluster.instances | int | `1` | Number of PostgreSQL instances in the cluster |
| cloudnativepg.cluster.monitoring.enablePodMonitor | bool | `false` | Enable Prometheus PodMonitor for metrics collection |
| cloudnativepg.cluster.nameOverride | string | `""` | Override cluster name. If empty, uses "{{ release-name }}-pg" |
| cloudnativepg.cluster.postgresql | object | `{"parameters":{}}` | Additional PostgreSQL configuration parameters Example: postgresql:   parameters:     max_connections: "200"     shared_buffers: "256MB" |
| cloudnativepg.cluster.resources | object | `{}` | Resource limits and requests for PostgreSQL containers Example: resources:   limits:     cpu: "1"     memory: "1Gi"   requests:     cpu: "100m"     memory: "256Mi" |
| cloudnativepg.cluster.storage.size | string | `"20Gi"` | Storage size for PostgreSQL data |
| cloudnativepg.cluster.storage.storageClass | string | `"gp2"` | Storage class name. Change to your storage class |
| cloudnativepg.enabled | bool | `true` | Enable CloudNativePG cluster deployment |
| cloudnativepg.operator | object | `{"enabled":false,"namespace":"cnpg-system"}` | Set to true to install the CloudNativePG operator via Helm dependency |
| cloudnativepg.operator.namespace | string | `"cnpg-system"` | Namespace where the CloudNativePG operator will be installed When enabled, the operator should be installed in this dedicated namespace |
| commonAnnotations | object | `{}` | Additional annotations to apply to all resources Example: commonAnnotations:   monitoring.coreos.com/scrape: "true"   prometheus.io/port: "8080" |
| commonLabels | object | `{}` | Additional labels to apply to all resources Example: commonLabels:   environment: production   team: platform |
| fullnameOverride | string | `""` | Override the full qualified app name |
| global.namespace | string | `""` | Global namespace override. If empty, uses release namespace |
| nameOverride | string | `""` | Override name of app |
| nodeSelector | object | `{}` | Node selector for all pods Example: nodeSelector:   kubernetes.io/os: linux   node-role.kubernetes.io/worker: "true" |
| strimzi-kafka-operator.watchAnyNamespace | bool | `true` | Configure the Strimzi operator to watch all namespaces This allows the operator to manage Kafka resources across all namespaces |
| strimzi.enabled | bool | `true` | Enable Strimzi Kafka cluster deployment |
| strimzi.kafka.annotations.kraft.enabled | bool | `true` | Enable KRaft mode (no ZooKeeper required) |
| strimzi.kafka.annotations.nodePools.enabled | bool | `true` | Use KafkaNodePool resources for node management |
| strimzi.kafka.config | object | `{"default.replication.factor":1,"min.insync.replicas":1,"offsets.topic.replication.factor":1,"transaction.state.log.min.isr":1,"transaction.state.log.replication.factor":1}` | Kafka configuration parameters for brokers With 1 broker, keep replication factors at 1 (increase when scaling out) |
| strimzi.kafka.entityOperator.topicOperator.enabled | bool | `true` | Enable Kafka Topic Operator for topic management |
| strimzi.kafka.entityOperator.userOperator.enabled | bool | `true` | Enable Kafka User Operator for user management |
| strimzi.kafka.listeners | list | `[{"authentication":{"type":"scram-sha-512"},"name":"plain","port":9092,"tls":false,"type":"internal"}]` | Kafka listeners define how clients connect to the cluster |
| strimzi.kafka.nameOverride | string | `""` | Override Kafka cluster name. If empty, uses "{{ release-name }}-kafka" |
| strimzi.kafka.resources | object | `{}` | Resource limits and requests for Kafka brokers Example: resources:   limits:     cpu: "1"     memory: "2Gi"   requests:     cpu: "100m"     memory: "512Mi" |
| strimzi.nodePools.brokers.enabled | bool | `true` | Enable broker node pool deployment |
| strimzi.nodePools.brokers.replicas | int | `1` | Number of broker replicas |
| strimzi.nodePools.brokers.resources | object | `{}` | Resource limits and requests for broker nodes Example: resources:   limits:     cpu: "1"     memory: "2Gi"   requests:     cpu: "200m"     memory: "512Mi" |
| strimzi.nodePools.brokers.roles | list | `["broker"]` | Node pool roles for brokers |
| strimzi.nodePools.brokers.storage.type | string | `"jbod"` | Storage type for broker nodes (JBOD allows multiple volumes) |
| strimzi.nodePools.brokers.storage.volumes | list | `[{"class":"gp2","deleteClaim":false,"id":0,"size":"100Gi","type":"persistent-claim"}]` | Storage volumes configuration for brokers |
| strimzi.nodePools.controllers.enabled | bool | `true` | Enable controller node pool deployment |
| strimzi.nodePools.controllers.replicas | int | `1` | Number of controller replicas |
| strimzi.nodePools.controllers.resources | object | `{}` | Resource limits and requests for controller nodes Example: resources:   limits:     cpu: "500m"     memory: "1Gi"   requests:     cpu: "100m"     memory: "256Mi" |
| strimzi.nodePools.controllers.roles | list | `["controller"]` | Node pool roles for controllers |
| strimzi.nodePools.controllers.storage.class | string | `"gp2"` | Storage class for controller nodes |
| strimzi.nodePools.controllers.storage.deleteClaim | bool | `false` | Whether to delete PVC when node pool is deleted |
| strimzi.nodePools.controllers.storage.size | string | `"20Gi"` | Storage size for controller nodes |
| strimzi.nodePools.controllers.storage.type | string | `"persistent-claim"` | Storage type for controller nodes |
| strimzi.operator | object | `{"enabled":false,"namespace":"strimzi-system"}` | Set to true to install the Strimzi Kafka operator via Helm dependency |
| strimzi.operator.namespace | string | `"strimzi-system"` | Namespace where the Strimzi Kafka operator will be installed When enabled, the operator should be installed in this dedicated namespace |
| strimzi.topics.events.config | object | `{"cleanup.policy":"delete","retention.ms":604800000}` | Topic configuration parameters |
| strimzi.topics.events.enabled | bool | `true` | Enable main events topic creation |
| strimzi.topics.events.name | string | `"app-events"` | Topic name for main application events |
| strimzi.topics.events.partitions | int | `6` | Number of partitions (adjust for throughput) |
| strimzi.topics.events.replicas | int | `1` | Number of replicas (set to 3 when you scale brokers to 3) |
| strimzi.users.app.authentication.password | object | `{"secretKey":"KAFKA_SASL_PASSWORD","secretName":"app-secrets"}` | Password configuration sourced from Kubernetes secret |
| strimzi.users.app.authentication.type | string | `"scram-sha-512"` | Authentication type for Kafka user |
| strimzi.users.app.enabled | bool | `true` | Enable main application user creation |
| strimzi.users.app.name | string | `"app-user"` | Kafka user name for main application |
| tolerations | list | `[]` | Tolerations for all pods Example: tolerations: - key: "key1"   operator: "Equal"   value: "value1"   effect: "NoSchedule" - key: "key2"   operator: "Exists"   effect: "NoExecute" |
