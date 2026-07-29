# op-kits: provisioning Postgres / Kafka / Valkey and auto-wiring

`charts/op-kits/` is a **thin CR-emitter**. It renders custom resources for
CloudNativePG (Postgres), Strimzi (Kafka), and the Hyperspike Valkey operator.
It provisions **no operator logic** — the operators themselves **must be
pre-installed** in the cluster.

> Read `charts/op-kits/values.yaml` and `charts/op-kits/templates/NOTES.txt`
> live for exact keys and the emitted connection info.

## Prerequisites (verify before offering this path)

Check the operator CRDs exist:
```
kubectl get crd clusters.postgresql.cnpg.io        # CloudNativePG
kubectl get crd kafkas.kafka.strimzi.io            # Strimzi
kubectl get crd valkeys.hyperspike.io              # Valkey (name may vary)
```
If a CRD is missing, the operator is not installed — tell the user to install
it first (recommended namespaces: `cnpg-system`, `strimzi-system` with
`watchAnyNamespace=true`, `valkey-system`). Do not apply op-kits CRs without
the matching operator, or the CRs will sit unreconciled.

## Component toggles

- `cloudnativepg.enabled` → emits a `Cluster` + optional `Database` CRs.
- `strimzi.enabled` → emits a KRaft-mode `Kafka` + node pools + `KafkaTopic` +
  `KafkaUser` CRs.
- `valkey.enabled` → emits a Valkey `Cluster` CR. **Note:** the Studio chart has
  no Valkey/Redis consumer today, so Valkey is only relevant to rasa's
  `tracker_store: redis` if the user wires it manually.

## Auto-wire mapping (op-kits → app chart)

After generating op-kits values, translate its emitted outputs into the app
chart's values/secret. These are the conventions op-kits' NOTES print.

### CloudNativePG → studio `config.database`

| op-kits output | → app chart |
|----------------|-------------|
| Read-write service `<cluster>-rw.<ns>.svc.cluster.local` : `5432` | `config.database.host` / `port` |
| App secret `<cluster>-app` (or superuser `<cluster>-superuser`) | source of `DATABASE_PASSWORD` in `studio-secrets` |
| Bootstrap DB `app` / owner `appuser` (default) | either point `backendDatabaseName`/`keycloakDatabaseName` at created DBs, **or** create `studio` + `keycloak` DBs via `cloudnativepg.databases:` CRs |

Default bootstrap creates only the `app` database. To get Studio's `studio` and
`keycloak` databases, add entries under `cloudnativepg.databases:` (owner
`appuser`) or Studio must be pointed at existing DBs.

### Strimzi → studio `eventIngestion.environmentVariables`

| op-kits output | → app chart |
|----------------|-------------|
| Bootstrap `<kafkaName>-kafka-bootstrap.<ns>.svc.cluster.local:9092` | `KAFKA_BROKER_ADDRESS` |
| Listener auth `scram-sha-512` | `KAFKA_SASL_MECHANISM=SCRAM-SHA-512` |
| `KafkaUser` name | `KAFKA_SASL_USERNAME` |
| Generated user secret (named after the `KafkaUser`, key `password`) — or a pre-set secret via `strimzi.users.root.authentication.password: {secretName, secretKey}` | `KAFKA_SASL_PASSWORD` in `studio-secrets` |
| `KafkaTopic` names | `KAFKA_TOPIC` / `KAFKA_DLQ_TOPIC` (create `rasa-events`, `rasa-events-dlq`) |

Default listeners: `plain:9092` (SCRAM-SHA-512, internal) and `tls:9093`;
optional `externalListener` (LoadBalancer `:9094`).

### Strimzi → rasa `event_broker`

For rasa's `settings.endpoints.event_broker`, wire the same bootstrap address,
`security_protocol`, `sasl_mechanism`, `sasl_username`, and `sasl_password`
(the last as `${KAFKA_PASSWORD}` via `additionalEnv`, per
`rasa-endpoints-credentials.md`).

## Workflow note

Generate `op-kits-values.yaml` as a **separate** release from the app chart
(op-kits is its own chart). Apply op-kits first, wait for the operator to
reconcile the CRs to Ready, then install the app chart with the auto-wired
values so the connection targets already exist.
