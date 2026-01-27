# op-kits

Operator Kits Helm Chart

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- CloudNativePG operator must be pre-installed in the cluster
- Strimzi Kafka operator must be pre-installed in the cluster
- Valkey operator must be pre-installed in the cluster

## Installing the Chart

You can install the chart from either the OCI registry or the GitHub Helm repository.

### Option 1: Install from OCI Registry

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/op-kits --version 0.4.0
```

### Option 2: Install from GitHub Helm Repository

First, add the Rasa Helm repository:

```console
$ helm repo add rasa https://helm.rasa.com/charts
$ helm repo update
```

Then install the chart:

```console
$ helm install my-release rasa/op-kits --version 0.4.0
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

> **Note**: This only removes application resources (PostgreSQL and Kafka clusters). The operators will remain installed and can be reused for other deployments.

## Pull the Chart

You can pull the chart from either source:

### From OCI Registry:

```console
$ helm pull oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/op-kits --version 0.4.0
```

### From GitHub Helm Repository:

```console
$ helm pull rasa/op-kits --version 0.4.0
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
$ helm install strimzi-operator oci://quay.io/strimzi-helm/strimzi-kafka-operator \
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

Once operators are installed and running, you can deploy your application resources using either installation method:

```console
# Option 1: Install from OCI Registry
$ helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/op-kits \
    --version 0.4.0 \
    --namespace my-app-namespace \
    --create-namespace

# Option 2: Install from GitHub Helm Repository (after adding the repo)
$ helm install my-release rasa/op-kits \
    --version 0.4.0 \
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

## Resource Naming

All resource names are generated based on the Helm release name. The chart uses a consistent naming pattern to ensure uniqueness and clarity.

### Base Naming Logic

The chart uses a "fullname" template that combines the release name with the chart name:

- **If `fullnameOverride` is set**: Uses the specified value directly
- **If release name contains chart name** (e.g., release `my-op-kits`): Uses just the release name
- **Otherwise**: Combines as `{release-name}-{chart-name}` (e.g., `my-app-op-kits`)

All names are truncated to 63 characters to comply with Kubernetes DNS naming requirements.

### Resource-Specific Names

Based on the fullname, resources are named as follows:

#### PostgreSQL (CloudNativePG)
- **Cluster name**: `{fullname}-pg`
  - Override: Set `cloudnativepg.cluster.nameOverride`

#### Kafka (Strimzi)
- **Kafka cluster**: `{fullname}-kafka`
  - Override: Set `strimzi.kafka.nameOverride`
- **Controller node pool**: `{kafka-cluster-name}-controllers`
- **Broker node pool**: `{kafka-cluster-name}-brokers`
- **Kafka users**: `{release-name}-user` (default) or `strimzi.users.<user>.name` if specified
- **Kafka topics**: Uses the topic name directly from `strimzi.topics.<topic>.name`

#### Valkey
- **Cluster name**: `{fullname}-valkey`
  - Override: Set `valkey.cluster.nameOverride`

### Examples

For a release named `my-app`:

```yaml
# Default names (assuming chart name is "op-kits")
PostgreSQL Cluster: my-app-op-kits-pg
Kafka Cluster: my-app-op-kits-kafka
Kafka Controller Node Pool: my-app-op-kits-kafka-controllers
Kafka Broker Node Pool: my-app-op-kits-kafka-brokers
Kafka User: my-app-user
Valkey Cluster: my-app-op-kits-valkey
```

For a release named `my-op-kits` (contains chart name):

```yaml
# Names (release name contains chart name)
PostgreSQL Cluster: my-op-kits-pg
Kafka Cluster: my-op-kits-kafka
Kafka Controller Node Pool: my-op-kits-kafka-controllers
Kafka Broker Node Pool: my-op-kits-kafka-brokers
Kafka User: my-op-kits-user
Valkey Cluster: my-op-kits-valkey
```

### Overriding Names

You can override resource names using the following values:

```yaml
# Override all resource names
fullnameOverride: "custom-name"

# Override individual resource names
cloudnativepg:
  cluster:
    nameOverride: "custom-pg-cluster"

strimzi:
  kafka:
    nameOverride: "custom-kafka-cluster"
  users:
    app:
      name: "custom-kafka-user"

valkey:
  cluster:
    nameOverride: "custom-valkey-cluster"
```

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

### Resource Configuration

#### Kafka Resources

CPU and memory resources for Kafka components are configured in specific sections:

- **Kafka brokers and controllers**: Configure resources under `strimzi.nodePools.controllers.resources` and `strimzi.nodePools.brokers.resources`
- **Entity operators (Topic and User operators)**: Configure resources under `strimzi.kafka.entityOperator.topicOperator.resources` and `strimzi.kafka.entityOperator.userOperator.resources`

Example:

```yaml
strimzi:
  nodePools:
    controllers:
      resources:
        limits:
          cpu: "500m"
          memory: "1Gi"
        requests:
          cpu: "100m"
          memory: "256Mi"
    brokers:
      resources:
        limits:
          cpu: "1"
          memory: "2Gi"
        requests:
          cpu: "200m"
          memory: "512Mi"
  kafka:
    entityOperator:
      topicOperator:
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "100m"
            memory: "128Mi"
      userOperator:
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "100m"
            memory: "128Mi"
```

> **Note**: The `.spec.kafka.resources` field is deprecated in Strimzi v1 API. Always use KafkaNodePool resources for broker and controller resource configuration.

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

### Kafka Users and Passwords

- If you do not specify a password under `strimzi.users.<user>.authentication.password`, Strimzi will generate one automatically and store it in a Secret named exactly as the KafkaUser. The password is stored under the key `password`.
- If you want to use your own password, reference an existing Secret via:

```yaml
strimzi:
  users:
    app:
      enabled: true
      authentication:
        type: scram-sha-512
        password:
          secretName: app-secrets
          secretKey: KAFKA_SASL_PASSWORD
```

To read the password:

```console
# Operator-generated password (Secret name equals KafkaUser name)
$ kubectl get secret -n <namespace> <kafka-user-name> -o jsonpath='{.data.password}' | base64 -d

# User-provided secret
$ kubectl get secret -n <namespace> <secretName> -o jsonpath='{.data.<secretKey>}' | base64 -d
```

### Kafka External Access

The chart supports external access to Kafka via LoadBalancer. This is useful when you need to connect to Kafka from outside the Kubernetes cluster.

#### Enabling External Access

To enable external access, configure the external listener in your values file:

```yaml
strimzi:
  kafka:
    externalListener:
      enabled: true
      listener:
        name: external
        port: 9094
        type: loadbalancer  # Can also be: nodeport, ingress, route (OpenShift)
        tls: false  # Set to true for TLS encryption
        authentication:
          type: scram-sha-512
        configuration:
          bootstrap:
            # Optional: Custom DNS names for TLS certificate SANs
            # alternativeNames:
            #   - kafka-bootstrap.example.com
            #   - kafka.example.com
            # Optional: LoadBalancer annotations (AWS example)
            # annotations:
            #   service.beta.kubernetes.io/aws-load-balancer-type: "external"
            #   service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
            #   service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
          brokers:
            # - broker: 0
            #   # Optional: Custom advertised hostname for this broker
            #   advertisedHost: kafka-broker-0.example.com
            #   annotations:
            #     service.beta.kubernetes.io/aws-load-balancer-type: "external"
```

#### TLS Configuration

**With TLS disabled** (`tls: false`):
- Simpler configuration, no certificate management needed
- Data is transmitted in plaintext (use only in trusted networks)
- Authentication via SCRAM-SHA-512 still protects credentials
- Suitable for development or VPC-internal access

**With TLS enabled** (`tls: true`):
- Strimzi automatically generates TLS certificates
- Certificates include custom DNS names from `alternativeNames`
- Data is encrypted in transit
- Recommended for production and internet-facing deployments

To retrieve the cluster CA certificate for TLS connections:

```console
# Get the cluster CA certificate
$ kubectl get secret <kafka-cluster-name>-cluster-ca-cert \
    -n <namespace> \
    -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt

# Use with your Kafka client
$ kafka-console-consumer.sh \
    --bootstrap-server <loadbalancer-ip>:9094 \
    --topic my-topic \
    --consumer.config client.properties
```

Where `client.properties` contains:

```properties
security.protocol=SASL_SSL
sasl.mechanism=SCRAM-SHA-512
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
  username="<kafka-user>" \
  password="<kafka-password>";
ssl.truststore.location=/path/to/ca.crt
ssl.truststore.type=PEM
```

#### Cloud Provider Configuration

**AWS (using AWS Load Balancer Controller):**

```yaml
strimzi:
  kafka:
    externalListener:
      enabled: true
      listener:
        configuration:
          bootstrap:
            annotations:
              service.beta.kubernetes.io/aws-load-balancer-type: "external"
              service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
              service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
              service.beta.kubernetes.io/aws-load-balancer-healthcheck-port: "9094"
              service.beta.kubernetes.io/aws-load-balancer-healthcheck-healthy-threshold: "3"
              service.beta.kubernetes.io/aws-load-balancer-healthcheck-unhealthy-threshold: "3"
          brokers:
            - broker: 0
              advertisedHost: kafka-broker-0.example.com
              annotations:
                service.beta.kubernetes.io/aws-load-balancer-type: "external"
                service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
```

**GCP (using GCP Load Balancer):**

```yaml
strimzi:
  kafka:
    externalListener:
      enabled: true
      listener:
        configuration:
          bootstrap:
            annotations:
              cloud.google.com/load-balancer-type: "External"
```

**Azure (using Azure Load Balancer):**

```yaml
strimzi:
  kafka:
    externalListener:
      enabled: true
      listener:
        configuration:
          bootstrap:
            annotations:
              service.beta.kubernetes.io/azure-load-balancer-internal: "false"
```

#### Getting External Access Information

After enabling external access, get the LoadBalancer address:

```console
# Get the bootstrap LoadBalancer address
$ kubectl get service <kafka-cluster-name>-kafka-external-bootstrap \
    -n <namespace> \
    -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Or for IP-based LoadBalancers
$ kubectl get service <kafka-cluster-name>-kafka-external-bootstrap \
    -n <namespace> \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Get broker-specific LoadBalancer addresses
$ kubectl get service <kafka-cluster-name>-kafka-0 -n <namespace>
```

#### Multi-Broker External Access

For production deployments with multiple brokers, configure each broker with its own advertised hostname:

```yaml
strimzi:
  nodePools:
    brokers:
      replicas: 3
  kafka:
    externalListener:
      enabled: true
      listener:
        configuration:
          brokers:
            - broker: 0
              advertisedHost: kafka-broker-0.example.com
            - broker: 1
              advertisedHost: kafka-broker-1.example.com
            - broker: 2
              advertisedHost: kafka-broker-2.example.com
```

Configure DNS records to point each hostname to its respective LoadBalancer address.

#### Security Considerations

When exposing Kafka externally:

1. **Always use authentication** - The chart defaults to SCRAM-SHA-512
2. **Consider TLS encryption** - Use `tls: true` for internet-facing deployments
3. **Restrict source IPs** - Use `loadBalancerSourceRanges` to limit access:

```yaml
strimzi:
  kafka:
    externalListener:
      listener:
        configuration:
          bootstrap:
            loadBalancerSourceRanges:
              - "203.0.113.0/24"  # Your office IP range
              - "198.51.100.0/24"  # Your VPN IP range
```

4. **Use network policies** - The chart includes network policies that can be enabled
5. **Monitor access** - Enable audit logging and monitor connection attempts

## Values

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| affinity | object | Affinity rules for all pods Example: affinity:   nodeAffinity:     requiredDuringSchedulingIgnoredDuringExecution:       nodeSelectorTerms:       - matchExpressions:         - key: kubernetes.io/os           operator: In           values:           - linux         - key: node-role.kubernetes.io/worker           operator: In           values:            - "true"   podAntiAffinity:     preferredDuringSchedulingIgnoredDuringExecution:     - weight: 100       podAffinityTerm:         labelSelector:           matchExpressions:           - key: app.kubernetes.io/name             operator: In             values:             - op-kits         topologyKey: kubernetes.io/hostname | `{}` |
| cloudnativepg.cluster.annotations | object | Additional annotations to apply to the PostgreSQL Cluster resource Example: annotations:   backup.postgresql.cnpg.io/enabled: "true"   monitoring.postgresql.cnpg.io/scrape: "true" | `{}` |
| cloudnativepg.cluster.bootstrap.initdb.database | string | Database name to create during initialization | `"app"` |
| cloudnativepg.cluster.bootstrap.initdb.owner | string | Database owner/user to create during initialization | `"appuser"` |
| cloudnativepg.cluster.enableSuperuserAccess | bool | Enable superuser access (creates <cluster>-superuser secret) | `true` |
| cloudnativepg.cluster.image | object | PostgreSQL container image to use | `{"repository":"ghcr.io/cloudnative-pg/postgresql","tag":"16"}` |
| cloudnativepg.cluster.instances | int | Number of PostgreSQL instances in the cluster | `1` |
| cloudnativepg.cluster.monitoring.enablePodMonitor | bool | Enable Prometheus PodMonitor for metrics collection | `false` |
| cloudnativepg.cluster.nameOverride | string | Override cluster name. If empty, uses "{{ release-name }}-pg" | `""` |
| cloudnativepg.cluster.postgresql | object | Additional PostgreSQL configuration parameters Example: postgresql:   parameters:     max_connections: "200"     shared_buffers: "256MB" | `{"parameters":{}}` |
| cloudnativepg.cluster.resources | object | Resource limits and requests for PostgreSQL containers Example: resources:   limits:     cpu: "1"     memory: "1Gi"   requests:     cpu: "100m"     memory: "256Mi" | `{}` |
| cloudnativepg.cluster.storage.size | string | Storage size for PostgreSQL data | `"15Gi"` |
| cloudnativepg.cluster.storage.storageClass | string | Storage class name. Change to your storage class | `"gp2"` |
| cloudnativepg.enabled | bool | Enable CloudNativePG cluster deployment | `true` |
| commonAnnotations | object | Additional annotations to apply to all resources Example: commonAnnotations:   monitoring.coreos.com/scrape: "true"   prometheus.io/port: "8080" | `{}` |
| commonLabels | object | Additional labels to apply to all resources Example: commonLabels:   environment: production   team: platform | `{}` |
| fullnameOverride | string | Override the full qualified app name | `""` |
| global.namespace | string | Global namespace override. If empty, uses release namespace | `""` |
| nameOverride | string | Override name of app | `""` |
| nodeSelector | object | Node selector for all pods Example: nodeSelector:   kubernetes.io/os: linux   node-role.kubernetes.io/worker: "true" | `{}` |
| strimzi.enabled | bool | Enable Strimzi Kafka cluster deployment | `true` |
| strimzi.kafka.annotations | object | Annotations to apply to the Kafka Cluster resource Includes both operator configuration and custom annotations Example: annotations:   strimzi.io/kraft: "enabled"           # Enable KRaft mode (no ZooKeeper)   strimzi.io/node-pools: "enabled"     # Use KafkaNodePool resources   strimzi.io/restart: "true"           # Custom restart annotation   kafka.strimzi.io/logging: "debug"    # Custom logging annotation | `{"strimzi.io/kraft":"enabled","strimzi.io/node-pools":"enabled"}` |
| strimzi.kafka.authorization.type | string |  | `"simple"` |
| strimzi.kafka.config | object | Kafka configuration parameters for brokers With 1 broker, keep replication factors at 1 (increase when scaling out) | `{"auto.create.topics.enable":true,"default.replication.factor":1,"min.insync.replicas":1,"offsets.topic.replication.factor":1,"transaction.state.log.min.isr":1,"transaction.state.log.replication.factor":1}` |
| strimzi.kafka.entityOperator.disableTopicFinalizer | bool | Resource limits and requests for User Operator Example: resources:   limits:     cpu: "500m"     memory: "512Mi"   requests:     cpu: "100m"     memory: "128Mi" | `true` |
| strimzi.kafka.entityOperator.topicOperator | object |  | `{}` |
| strimzi.kafka.entityOperator.userOperator | object | Resource limits and requests for Topic Operator Example: resources:   limits:     cpu: "500m"     memory: "512Mi"   requests:     cpu: "100m"     memory: "128Mi" | `{}` |
| strimzi.kafka.externalListener | object | External listener configuration for accessing Kafka from outside the cluster When enabled, this entire listener object is appended to the listeners array | `{"enabled":false,"listener":{"authentication":{"type":"scram-sha-512"},"configuration":{"bootstrap":null,"brokers":null},"name":"external","port":9094,"tls":false,"type":"loadbalancer"}}` |
| strimzi.kafka.externalListener.enabled | bool | Enable external access to Kafka via LoadBalancer | `false` |
| strimzi.kafka.externalListener.listener | object | Complete listener configuration (Strimzi Kafka listener spec) This allows full flexibility - any valid Strimzi listener configuration can be specified here | `{"authentication":{"type":"scram-sha-512"},"configuration":{"bootstrap":null,"brokers":null},"name":"external","port":9094,"tls":false,"type":"loadbalancer"}` |
| strimzi.kafka.externalListener.listener.configuration.brokers | string | Optional: DNS names for the bootstrap service (added to TLS certificate SANs) Uncomment and configure to use custom DNS names for the bootstrap service alternativeNames:   - kafka-bootstrap.example.com   - kafka.example.com annotations:   service.beta.kubernetes.io/aws-load-balancer-type: "external"   service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"   service.beta.kubernetes.io/aws-load-balancer-name: strimzi-kafka-bootstrap   service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"   service.beta.kubernetes.io/aws-load-balancer-healthcheck-port: "9094"   service.beta.kubernetes.io/aws-load-balancer-healthcheck-healthy-threshold: "3"   service.beta.kubernetes.io/aws-load-balancer-healthcheck-unhealthy-threshold: "3"   service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval: "10"   service.beta.kubernetes.io/aws-load-balancer-healthcheck-timeout: "10" | `nil` |
| strimzi.kafka.listeners | list | Kafka listeners define how clients connect to the cluster | `[{"authentication":{"type":"scram-sha-512"},"name":"plain","port":9092,"tls":false,"type":"internal"},{"authentication":{"type":"scram-sha-512"},"name":"tls","port":9093,"tls":true,"type":"internal"}]` |
| strimzi.kafka.nameOverride | string | Override Kafka cluster name. If empty, uses "{{ release-name }}-kafka" | `""` |
| strimzi.nodePools.brokers.enabled | bool | Enable broker node pool deployment | `true` |
| strimzi.nodePools.brokers.replicas | int | Number of broker replicas | `1` |
| strimzi.nodePools.brokers.resources | object | Resource limits and requests for broker nodes Example: resources:   limits:     cpu: "1"     memory: "2Gi"   requests:     cpu: "200m"     memory: "512Mi" | `{}` |
| strimzi.nodePools.brokers.roles | list | Node pool roles for brokers | `["broker"]` |
| strimzi.nodePools.brokers.storage.type | string | Storage type for broker nodes (JBOD allows multiple volumes) | `"jbod"` |
| strimzi.nodePools.brokers.storage.volumes | list | Storage volumes configuration for brokers | `[{"class":"gp2","deleteClaim":true,"id":0,"size":"10Gi","type":"persistent-claim"}]` |
| strimzi.nodePools.controllers.enabled | bool | Enable controller node pool deployment | `true` |
| strimzi.nodePools.controllers.replicas | int | Number of controller replicas | `1` |
| strimzi.nodePools.controllers.resources | object | Resource limits and requests for controller nodes Example: resources:   limits:     cpu: "500m"     memory: "1Gi"   requests:     cpu: "100m"     memory: "256Mi" | `{}` |
| strimzi.nodePools.controllers.roles | list | Node pool roles for controllers | `["controller"]` |
| strimzi.nodePools.controllers.storage.class | string | Storage class for controller nodes | `"gp2"` |
| strimzi.nodePools.controllers.storage.deleteClaim | bool | Whether to delete PVC when node pool is deleted | `true` |
| strimzi.nodePools.controllers.storage.size | string | Storage size for controller nodes | `"10Gi"` |
| strimzi.nodePools.controllers.storage.type | string | Storage type for controller nodes | `"persistent-claim"` |
| strimzi.nodePools.controllers.storage.volumeAttributesClass | string | Volume attributes class for the PVC (requires Kubernetes 1.34+) | `""` |
| strimzi.topics | object |  | `{}` |
| strimzi.users.root.authentication.type | string | Authentication type for Kafka user | `"scram-sha-512"` |
| strimzi.users.root.enabled | bool | Enable main application user creation | `true` |
| strimzi.users.root.name | string | Kafka user name. If empty, defaults to "<release-name>-user" | `""` |
| tolerations | list | Tolerations for all pods Example: tolerations: - key: "key1"   operator: "Equal"   value: "value1"   effect: "NoSchedule" - key: "key2"   operator: "Exists"   effect: "NoExecute" | `[]` |
| valkey.cluster.annotations | object | Additional annotations to apply to the Valkey Cluster resource Example: annotations:   valkey.hyperspike.io/monitoring: "enabled"   valkey.hyperspike.io/backup: "enabled" | `{}` |
| valkey.cluster.certIssuer | string | Certificate issuer name | `"selfsigned"` |
| valkey.cluster.certIssuerType | string | Certificate issuer type | `"ClusterIssuer"` |
| valkey.cluster.externalAccess.enabled | bool | Enable external access to Valkey cluster | `false` |
| valkey.cluster.externalAccess.type | string | Type of external access (LoadBalancer, NodePort, etc.) | `"LoadBalancer"` |
| valkey.cluster.image | string | Container image for Valkey image: "ghcr.io/hyperspike/valkey:8.0.2" | `""` |
| valkey.cluster.nameOverride | string | Override cluster name. If empty, uses "{{ release-name }}-valkey" | `""` |
| valkey.cluster.nodes | int | Number of primary nodes; set >1 only if you intend to run Valkey Cluster | `1` |
| valkey.cluster.replicas | int | Replicas per primary (0 = standalone, >0 = primary + replicas) | `0` |
| valkey.cluster.resources | object | Resource limits and requests for Valkey containers Example: resources:   limits:     cpu: "1"     memory: "1Gi"   requests:     cpu: "100m"     memory: "256Mi" | `{}` |
| valkey.cluster.servicePassword.key | string | Secret key for the Valkey password | `"VALKEY_PASSWORD"` |
| valkey.cluster.servicePassword.name | string | Secret name containing the Valkey password | `"app-secrets"` |
| valkey.cluster.servicePassword.optional | bool | Whether the service password is optional | `false` |
| valkey.cluster.storage.spec.accessModes | list | Access modes for Valkey storage | `["ReadWriteOnce"]` |
| valkey.cluster.storage.spec.resources | object | Storage size for Valkey data | `{"requests":{"storage":"10Gi"}}` |
| valkey.cluster.storage.spec.storageClassName | string | Storage class name. Change to your storage class | `"gp2"` |
| valkey.cluster.tls | bool | Enable TLS (requires cert-manager) | `false` |
| valkey.cluster.volumePermissions | bool | Enable volume permissions initialization | `true` |
| valkey.enabled | bool | Enable Valkey cluster deployment | `true` |
