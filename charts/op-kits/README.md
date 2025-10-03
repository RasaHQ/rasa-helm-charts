# op-kits

Operator Kits Helm Chart

![Version: 0.1.5](https://img.shields.io/badge/Version-0.1.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- CloudNativePG operator must be pre-installed in the cluster
- Strimzi Kafka operator must be pre-installed in the cluster
- Valkey operator must be pre-installed in the cluster

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/op-kits --version 0.1.5
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

> **Note**: This only removes application resources (PostgreSQL and Kafka clusters). The operators will remain installed and can be reused for other deployments.

## Pull the Chart

To pull chart contents for your own convenience:

```console
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/op-kits --version 0.1.5
```

## Operator Installation

Before installing this chart, you **must** install the required operators in your cluster. We recommend installing operators in their own dedicated namespaces for better separation and management.

### 1. CloudNativePG Operator

Install the CloudNativePG operator in its dedicated namespace:

```console
# Add the CloudNativePG Helm repository
$ helm repo add cnpg https://cloudnative-pg.github.io/charts
$ helm repo update

# Install CloudNativePG operator in cnpg-system namespace
$ helm install cnpg-operator cnpg/cloudnative-pg \
    --namespace cnpg-system \
    --create-namespace
```

### 2. Strimzi Kafka Operator

Install the Strimzi Kafka operator in its dedicated namespace with cluster-wide permissions:

```console
# Add the Strimzi Helm repository
$ helm repo add strimzi https://strimzi.io/charts/
$ helm repo update

# Install Strimzi operator in strimzi-system namespace
$ helm install strimzi-operator strimzi/strimzi-kafka-operator \
    --namespace strimzi-system \
    --create-namespace \
    --set watchAnyNamespace=true
```

> **Important**: The `watchAnyNamespace=true` setting allows the Strimzi operator to manage Kafka resources across all namespaces in the cluster. This is required for the operator to manage resources created by this chart in different namespaces.

### 3. Valkey Operator

Install the Valkey operator using the official Helm chart:

```console
# Add the Hyperspike Helm repository
$ helm repo add hyperspike https://charts.hyperspike.io
$ helm repo update

# Install Valkey operator in valkey-system namespace
$ helm install valkey-operator hyperspike/valkey-operator \
    --namespace valkey-system \
    --create-namespace
```

### 4. Verify Operator Installation

After installing the operators, verify they are running:

```console
# Check CloudNativePG operator
$ kubectl get pods -n cnpg-system

# Check Strimzi operator
$ kubectl get pods -n strimzi-system

# Check Valkey operator
$ kubectl get pods -n valkey-system
```

### 5. Install Application Resources

Once operators are installed and running, you can deploy your application resources:

```console
# Install the op-kits chart in your application namespace
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/op-kits \
    --version 0.1.5 \
    --namespace my-app-namespace \
    --create-namespace
```

## Uninstalling Operators

If you need to completely remove the operators from your cluster:

```console
# Remove CloudNativePG operator
$ helm uninstall cnpg-operator -n cnpg-system

# Remove Strimzi operator 
$ helm uninstall strimzi-operator -n strimzi-system

# Remove Valkey operator
$ helm uninstall valkey-operator -n valkey-system

# Optionally remove the namespaces (only if empty)
$ kubectl delete namespace cnpg-system strimzi-system valkey-system
```

> **Warning**: Removing operators will affect all PostgreSQL, Kafka, and Valkey clusters managed by them across the entire cluster.

## General Configuration

- **CloudNativePG**: Configure PostgreSQL clusters with customizable storage, instances, and monitoring
- **Strimzi Kafka**: Configure Kafka clusters with KRaft mode, node pools, topics, and users
- **Valkey**: Configure Redis-compatible in-memory data store clusters with persistence and replication
- **Storage Classes**: Make sure to set the correct storage class names based on your cluster configuration
- **Resource Management**: Configure CPU, memory limits and requests for optimal performance

## Important Configuration Notes

### Storage Configuration

PostgreSQL, Kafka, and Valkey require persistent storage. Update the storage class names in your values:

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

valkey:
  cluster:
    storage:
      spec:
        storageClassName: "your-storage-class"  # Update this
```

### Scaling Considerations

When scaling Kafka brokers, remember to adjust replication factors:

```yaml
strimzi:
  nodePools:
    brokers:
      replicas: 3  # Scale brokers
  kafka:
    config:
      default.replication.factor: 3  # Match your broker count
      min.insync.replicas: 2
  topics:
    events:
      replicas: 3  # Match your broker count
```

### Namespace Considerations

Since operators are installed cluster-wide but in dedicated namespaces, you can deploy multiple instances of this chart in different namespaces:

```console
# Deploy for development
$ helm install dev-app . --namespace development

# Deploy for staging 
$ helm install staging-app . --namespace staging

# Deploy for production
$ helm install prod-app . --namespace production
```

Each deployment will create its own PostgreSQL, Kafka, and Valkey clusters, all managed by the same operators.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for all pods Example: affinity:   nodeAffinity:     requiredDuringSchedulingIgnoredDuringExecution:       nodeSelectorTerms:       - matchExpressions:         - key: kubernetes.io/os           operator: In           values:           - linux         - key: node-role.kubernetes.io/worker           operator: In           values:            - "true"   podAntiAffinity:     preferredDuringSchedulingIgnoredDuringExecution:     - weight: 100       podAffinityTerm:         labelSelector:           matchExpressions:           - key: app.kubernetes.io/name             operator: In             values:             - op-kits         topologyKey: kubernetes.io/hostname |
| cloudnativepg.cluster.annotations | object | `{}` | Additional annotations to apply to the PostgreSQL Cluster resource Example: annotations:   backup.postgresql.cnpg.io/enabled: "true"   monitoring.postgresql.cnpg.io/scrape: "true" |
| cloudnativepg.cluster.bootstrap.initdb.database | string | `"app"` | Database name to create during initialization |
| cloudnativepg.cluster.bootstrap.initdb.owner | string | `"appuser"` | Database owner/user to create during initialization |
| cloudnativepg.cluster.enableSuperuserAccess | bool | `true` | Enable superuser access (creates <cluster>-superuser secret) |
| cloudnativepg.cluster.image | object | `{"repository":"ghcr.io/cloudnative-pg/postgresql","tag":"16"}` | PostgreSQL container image to use |
| cloudnativepg.cluster.instances | int | `1` | Number of PostgreSQL instances in the cluster |
| cloudnativepg.cluster.monitoring.enablePodMonitor | bool | `false` | Enable Prometheus PodMonitor for metrics collection |
| cloudnativepg.cluster.nameOverride | string | `""` | Override cluster name. If empty, uses "{{ release-name }}-pg" |
| cloudnativepg.cluster.postgresql | object | `{"parameters":{}}` | Additional PostgreSQL configuration parameters Example: postgresql:   parameters:     max_connections: "200"     shared_buffers: "256MB" |
| cloudnativepg.cluster.resources | object | `{}` | Resource limits and requests for PostgreSQL containers Example: resources:   limits:     cpu: "1"     memory: "1Gi"   requests:     cpu: "100m"     memory: "256Mi" |
| cloudnativepg.cluster.storage.size | string | `"15Gi"` | Storage size for PostgreSQL data |
| cloudnativepg.cluster.storage.storageClass | string | `"gp2"` | Storage class name. Change to your storage class |
| cloudnativepg.enabled | bool | `true` | Enable CloudNativePG cluster deployment |
| commonAnnotations | object | `{}` | Additional annotations to apply to all resources Example: commonAnnotations:   monitoring.coreos.com/scrape: "true"   prometheus.io/port: "8080" |
| commonLabels | object | `{}` | Additional labels to apply to all resources Example: commonLabels:   environment: production   team: platform |
| fullnameOverride | string | `""` | Override the full qualified app name |
| global.namespace | string | `""` | Global namespace override. If empty, uses release namespace |
| nameOverride | string | `""` | Override name of app |
| nodeSelector | object | `{}` | Node selector for all pods Example: nodeSelector:   kubernetes.io/os: linux   node-role.kubernetes.io/worker: "true" |
| strimzi.enabled | bool | `true` | Enable Strimzi Kafka cluster deployment |
| strimzi.kafka.annotations | object | `{"strimzi.io/kraft":"enabled","strimzi.io/node-pools":"enabled"}` | Annotations to apply to the Kafka Cluster resource Includes both operator configuration and custom annotations Example: annotations:   strimzi.io/kraft: "enabled"           # Enable KRaft mode (no ZooKeeper)   strimzi.io/node-pools: "enabled"     # Use KafkaNodePool resources   strimzi.io/restart: "true"           # Custom restart annotation   kafka.strimzi.io/logging: "debug"    # Custom logging annotation |
| strimzi.kafka.config | object | `{"default.replication.factor":1,"min.insync.replicas":1,"offsets.topic.replication.factor":1,"transaction.state.log.min.isr":1,"transaction.state.log.replication.factor":1}` | Kafka configuration parameters for brokers With 1 broker, keep replication factors at 1 (increase when scaling out) |
| strimzi.kafka.entityOperator.topicOperator | object | `{}` |  |
| strimzi.kafka.entityOperator.userOperator | object | `{}` |  |
| strimzi.kafka.image | object | `{"repository":"quay.io/strimzi/kafka","tag":"0.47.0-kafka-4.0.0"}` | Container image for Kafka image: "quay.io/strimzi/kafka:0.47.0-kafka-4.0.0" |
| strimzi.kafka.listeners | list | `[{"authentication":{"type":"scram-sha-512"},"name":"plain","port":9092,"tls":false,"type":"internal"}]` | Kafka listeners define how clients connect to the cluster |
| strimzi.kafka.nameOverride | string | `""` | Override Kafka cluster name. If empty, uses "{{ release-name }}-kafka" |
| strimzi.kafka.resources | object | `{}` | Resource limits and requests for Kafka brokers Example: resources:   limits:     cpu: "1"     memory: "2Gi"   requests:     cpu: "100m"     memory: "512Mi" |
| strimzi.nodePools.brokers.enabled | bool | `true` | Enable broker node pool deployment |
| strimzi.nodePools.brokers.replicas | int | `1` | Number of broker replicas |
| strimzi.nodePools.brokers.resources | object | `{}` | Resource limits and requests for broker nodes Example: resources:   limits:     cpu: "1"     memory: "2Gi"   requests:     cpu: "200m"     memory: "512Mi" |
| strimzi.nodePools.brokers.roles | list | `["broker"]` | Node pool roles for brokers |
| strimzi.nodePools.brokers.storage.type | string | `"jbod"` | Storage type for broker nodes (JBOD allows multiple volumes) |
| strimzi.nodePools.brokers.storage.volumes | list | `[{"class":"gp2","deleteClaim":true,"id":0,"size":"10Gi","type":"persistent-claim"}]` | Storage volumes configuration for brokers |
| strimzi.nodePools.controllers.enabled | bool | `true` | Enable controller node pool deployment |
| strimzi.nodePools.controllers.replicas | int | `1` | Number of controller replicas |
| strimzi.nodePools.controllers.resources | object | `{}` | Resource limits and requests for controller nodes Example: resources:   limits:     cpu: "500m"     memory: "1Gi"   requests:     cpu: "100m"     memory: "256Mi" |
| strimzi.nodePools.controllers.roles | list | `["controller"]` | Node pool roles for controllers |
| strimzi.nodePools.controllers.storage.class | string | `"gp2"` | Storage class for controller nodes |
| strimzi.nodePools.controllers.storage.deleteClaim | bool | `true` | Whether to delete PVC when node pool is deleted |
| strimzi.nodePools.controllers.storage.size | string | `"10Gi"` | Storage size for controller nodes |
| strimzi.nodePools.controllers.storage.type | string | `"persistent-claim"` | Storage type for controller nodes |
| strimzi.topics | object | `{}` |  |
| strimzi.users.app.authentication.password | object | `{"secretKey":"KAFKA_SASL_PASSWORD","secretName":"app-secrets"}` | Password configuration sourced from Kubernetes secret |
| strimzi.users.app.authentication.type | string | `"scram-sha-512"` | Authentication type for Kafka user |
| strimzi.users.app.enabled | bool | `true` | Enable main application user creation |
| strimzi.users.app.name | string | `"app-user"` | Kafka user name for main application |
| tolerations | list | `[]` | Tolerations for all pods Example: tolerations: - key: "key1"   operator: "Equal"   value: "value1"   effect: "NoSchedule" - key: "key2"   operator: "Exists"   effect: "NoExecute" |
| valkey.cluster.annotations | object | `{}` | Additional annotations to apply to the Valkey Cluster resource Example: annotations:   valkey.hyperspike.io/monitoring: "enabled"   valkey.hyperspike.io/backup: "enabled" |
| valkey.cluster.certIssuer | string | `"selfsigned"` | Certificate issuer name |
| valkey.cluster.certIssuerType | string | `"ClusterIssuer"` | Certificate issuer type |
| valkey.cluster.externalAccess.enabled | bool | `false` | Enable external access to Valkey cluster |
| valkey.cluster.externalAccess.type | string | `"LoadBalancer"` | Type of external access (LoadBalancer, NodePort, etc.) |
| valkey.cluster.image | string | `""` | Container image for Valkey image: "ghcr.io/hyperspike/valkey:8.0.2" |
| valkey.cluster.nameOverride | string | `""` | Override cluster name. If empty, uses "{{ release-name }}-valkey" |
| valkey.cluster.nodes | int | `1` | Number of primary nodes; set >1 only if you intend to run Valkey Cluster |
| valkey.cluster.replicas | int | `0` | Replicas per primary (0 = standalone, >0 = primary + replicas) |
| valkey.cluster.resources | list | `[]` | Resource limits and requests for Valkey containers Example: resources:   limits:     cpu: "1"     memory: "1Gi"   requests:     cpu: "100m"     memory: "256Mi" |
| valkey.cluster.servicePassword.key | string | `"VALKEY_PASSWORD"` | Secret key for the Valkey password |
| valkey.cluster.servicePassword.name | string | `"app-secrets"` | Secret name containing the Valkey password |
| valkey.cluster.servicePassword.optional | bool | `false` | Whether the service password is optional |
| valkey.cluster.storage.spec.accessModes | list | `["ReadWriteOnce"]` | Access modes for Valkey storage |
| valkey.cluster.storage.spec.resources | object | `{"requests":{"storage":"10Gi"}}` | Storage size for Valkey data |
| valkey.cluster.storage.spec.storageClassName | string | `"gp2"` | Storage class name. Change to your storage class |
| valkey.cluster.tls | bool | `false` | Enable TLS (requires cert-manager) |
| valkey.cluster.volumePermissions | bool | `true` | Enable volume permissions initialization |
| valkey.enabled | bool | `true` | Enable Valkey cluster deployment |
