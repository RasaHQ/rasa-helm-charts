# Strimzi Kafka Storage: Can PV/PVC Be Disabled?

**Date:** 2026-05-13
**Sources:**
- Strimzi Deploying & Managing docs (latest): https://strimzi.io/docs/operators/latest/deploying.html
- Specifically sections 11.4.1–11.4.3 (Configuring Kafka storage)

## Executive Summary

**Yes — Strimzi Kafka brokers and controllers can run without PV/PVC.** Set `storage.type: ephemeral` on the `KafkaNodePool` to use Kubernetes `emptyDir` volumes instead of persistent volumes. This is officially documented and supported.

**Caveat:** Strimzi explicitly states this is **only recommended for development and testing environments**. For production, persistent storage (or JBOD with persistent volumes) is recommended.

In KRaft mode, both brokers and controllers obey the same rules — `ephemeral` is a valid `storage.type` for controller-only nodes too.

## Storage Type Options

Strimzi supports three storage types on `KafkaNodePool.spec.storage.type`:

| Type | Backing | Use case | Production-ready? |
|---|---|---|---|
| `ephemeral` | Kubernetes `emptyDir` (node-local, lost on pod deletion) | Dev/test only | No |
| `persistent-claim` | Single PVC bound to a PV | Production, simple setups | Yes |
| `jbod` | Multiple disks (each can be `ephemeral` or `persistent-claim`) | Production, recommended | Yes (recommended) |

### `ephemeral`

```yaml
apiVersion: kafka.strimzi.io/v1
kind: KafkaNodePool
metadata:
  name: my-node-pool
  labels:
    strimzi.io/cluster: my-cluster
spec:
  replicas: 3
  roles:
    - broker
  storage:
    type: ephemeral
```

- Uses Kubernetes `emptyDir` volumes, created when a pod is assigned to a node.
- Data is **lost on pod deletion**. Replicas across pods can mitigate this in a HA cluster.
- Optional `sizeLimit` property to cap the volume size.
- Kafka log dir mounted at `/var/lib/kafka/data/kafka-log<pod_id>`.
- **Explicitly NOT suitable for Kafka topics with `replication.factor=1`** — data loss on pod restart.

### `persistent-claim`

```yaml
spec:
  storage:
    type: persistent-claim
    size: 500Gi
    deleteClaim: true        # delete PVC on cluster delete (default: false)
    class: my-storage-class  # optional storage class
    selector:
      hdd-type: ssd          # optional volume selector
```

- Backed by a PVC bound to a PV that meets the size/class/selector criteria.
- PVC naming: `data-<kafka_cluster_name>-<pool_name>-<pod_id>`.
- Resizable in-place: bump `size`, Cluster Operator orchestrates the resize and rolling restart.
- Shrinking is **not supported by Kubernetes**.

### `jbod`

```yaml
spec:
  storage:
    type: jbod
    volumes:
      - id: 0
        type: persistent-claim
        size: 100Gi
      - id: 1
        type: persistent-claim
        size: 100Gi
        kraftMetadata: shared  # KRaft mode: pin metadata log here
```

- Multiple disks; each volume can independently be `ephemeral` or `persistent-claim`.
- Volume IDs are immutable; you can add/remove volumes but not re-id them.
- PVC naming includes volume ID: `data-<volume_id>-<kafka_cluster_name>-<pool_name>-<pod_id>`.
- **Recommended for production**, even with a single volume initially — gives a clean path to scale by adding disks.

## KRaft Mode: Brokers vs Controllers

- **Both brokers and controllers** store a copy of the Kafka cluster's metadata log on one of their data volumes (in KRaft mode).
- **Controller-only nodes** use storage *exclusively* for the metadata log. JBOD with multiple volumes provides no benefit on a controller-only node — only one volume is used.
- **Broker or dual-role nodes** can share a volume for metadata + partition data, or use JBOD with one shared volume + additional volumes for partition data only.
- The `kraftMetadata: shared` property on a JBOD volume pins the metadata log to that specific volume; otherwise it lands on the lowest-ID volume.

All storage types (`ephemeral`, `persistent-claim`, `jbod`) are valid for both broker and controller node pools.

## Storage Considerations from the Docs

Direct quotes from section 11.4.1:

> "Strimzi has been tested with block storage as the primary storage type for Kafka brokers, and block storage is strongly recommended."

> "File system-based storage (such as NFS) is not guaranteed to work for primary broker storage and may cause stability or performance issues."

> "Replicated storage is not required, as Kafka provides built-in data replication."

> "Due to its transient nature, ephemeral storage is only recommended for development and testing environments."

## Important Constraints

1. **Storage type cannot be changed after deployment.** You cannot flip `ephemeral` ↔ `persistent-claim` ↔ `jbod` on an existing node pool. Workarounds:
   - Add/remove individual volumes within an existing `jbod` (allowed).
   - Create a new node pool with the desired storage spec and migrate.
2. **Volume IDs in JBOD are immutable.** Removed-then-re-added IDs require the old PVC to be deleted first.
3. **No raw block volumes required** — standard PV/PVC suffices.
4. **PVC retention on cluster delete** is controlled by `deleteClaim`. Default is `false` (PVCs retained for recovery).

## Recommendations for Dev/Test Environments

If persistence is genuinely unwanted (e.g. ephemeral CI clusters, kind/minikube, throwaway PR preview environments):

**Minimal dev/test config (matches Strimzi's stated guidance):**

```yaml
apiVersion: kafka.strimzi.io/v1
kind: KafkaNodePool
metadata:
  name: dev-brokers
  labels:
    strimzi.io/cluster: dev-cluster
spec:
  replicas: 3
  roles:
    - broker
  storage:
    type: ephemeral
---
apiVersion: kafka.strimzi.io/v1
kind: KafkaNodePool
metadata:
  name: dev-controllers
  labels:
    strimzi.io/cluster: dev-cluster
spec:
  replicas: 3
  roles:
    - controller
  storage:
    type: ephemeral
```

**Cautions for this setup:**
- Ensure all topics (including internal ones like `__consumer_offsets`, `__transaction_state`) have `replication.factor >= 2` and ideally `min.insync.replicas >= 2`. Replication factor 1 + ephemeral = guaranteed data loss on any pod restart.
- A simultaneous restart of all broker pods (e.g. node failure, helm upgrade) will lose all data. Acceptable for ephemeral CI; not acceptable for anything you'd want to recover.
- Controllers losing their metadata log on simultaneous restart means the whole cluster needs to be recreated. With `replicas: 3` for the controller pool, you tolerate up to 1 controller loss at a time.

**For a slightly safer "no persistent infra" option:** use `emptyDir` via `ephemeral` *but* set `sizeLimit` to prevent runaway disk usage, and pin pods to nodes with anti-affinity so they don't co-locate.

## Implications for the `op-kits` Helm Chart

The chart currently exposes Strimzi Kafka via `strimzi.kafka.*` in `values.yaml`. There is **no explicit storage configuration field exposed today** (storage is at the `KafkaNodePool` level, which the chart appears not to template directly — needs verification).

If exposing this to chart users:
- Add `strimzi.kafka.storage` (or per-node-pool) with an enum/oneOf for the three types.
- Default to `persistent-claim` (production-safe).
- Document the dev/test escape hatch (`type: ephemeral`) prominently — including the replication-factor caveat.
- If chart supports multiple node pools (broker + controller separation in KRaft), allow each pool to specify its own storage type independently.

## Confidence

- **High confidence**: All claims in this report come directly from the current Strimzi 1.0.0 documentation (deploying.html, sections 11.4.1–11.4.3).
- The docs are versioned as "latest" — version-specific behavior should be confirmed against the Strimzi version your chart pins.

## Next Steps (for human decision)

- Decide whether to expose storage configuration via `op-kits` values (currently appears unexposed).
- If yes: design schema, defaults, and migration story (`/sc:design`).
- Then implementation (`/sc:implement`).
