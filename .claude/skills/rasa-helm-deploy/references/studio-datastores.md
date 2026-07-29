# Studio: Postgres, Kafka & Keycloak connectivity

`charts/studio/` needs an **external** PostgreSQL and (if event ingestion is
on) an external **Kafka**. It bundles Keycloak by default. Studio does not ship
a database — see `op-kits-provisioning.md` to provision one in-cluster.

> Read `charts/studio/values.yaml` and `templates/studio/_env.tpl` live for the
> exact current keys. Concepts below are stable.

## PostgreSQL — `config.database`

| Key | Default | Meaning |
|-----|---------|---------|
| `config.database.host` | `""` | **Required** (schema-enforced). DB host/IP. |
| `config.database.port` | `"5432"` | Port (string). |
| `config.database.username` | `""` | Plain string **or** `{secretName, secretKey}`. |
| `config.database.password` | `{secretName: studio-secrets, secretKey: DATABASE_PASSWORD}` | Always a secret ref. |
| `config.database.backendDatabaseName` | `"studio"` | Studio's DB. |
| `config.database.keycloakDatabaseName` | `"keycloak"` | Keycloak's DB. **Must be a plain string** (goes into a JDBC URL). |
| `config.database.queryParams` | `""` | e.g. `sslmode=require&connect_timeout=30`. |
| `config.database.preferSSL` | `"true"` | SSL toggle (string). |
| `config.database.useAwsIamAuth` / `awsRegion` / `iamDbUsername` | `""` | AWS IAM auth path (alternative to a password). |

Studio and Keycloak use the **same** Postgres server by default but different
databases (`studio`, `keycloak`). Keycloak can point at a separate server via
`keycloak.database` (falls back to `config.database` for unset fields).

Prereq: create both databases (`studio`, `keycloak`) on the server before
install, unless you use op-kits to provision them.

## Kafka — `eventIngestion.environmentVariables`

Only `eventIngestion` talks to Kafka (Rasa Pro produces events, event-ingestion
consumes them into Postgres). Required only when `eventIngestion.enabled: true`
(default). For a minimal first deploy, set `eventIngestion.enabled: false`.

| Env var | Default | Purpose |
|---------|---------|---------|
| `KAFKA_BROKER_ADDRESS` | `""` | **Must set.** Bootstrap address. |
| `KAFKA_TOPIC` | `"rasa-events"` | Main topic. |
| `KAFKA_DLQ_TOPIC` | `"rasa-events-dlq"` | Dead-letter topic. |
| `KAFKA_GROUP_ID` | `"studio"` | Consumer group. |
| `KAFKA_SASL_MECHANISM` | `""` | `plain` / `SCRAM-SHA-256` / `SCRAM-SHA-512`. |
| `KAFKA_SASL_USERNAME` | `""` | SASL user. |
| `KAFKA_SASL_PASSWORD` | `secret: {name: studio-secrets, key: KAFKA_SASL_PASSWORD}` | SASL password. |
| `KAFKA_ENABLE_SSL` / `KAFKA_CUSTOM_SSL` / `KAFKA_CA_FILE` / `KAFKA_CERT_FILE` / `KAFKA_KEY_FILE` / `KAFKA_REJECT_UNAUTHORIZED` | `""` | TLS/mTLS options. |

## Keycloak — `config.keycloak`

Bundled by default (`keycloak.enabled: true`).

| Key | Default | Purpose |
|-----|---------|---------|
| `config.keycloak.url` | `""` | Override internal endpoint (`http(s)://<ingressHost>/auth`). Only needed if the cluster forces HTTP→HTTPS. |
| `config.keycloak.adminUsername` | `"kcadmin"` | Admin console user. |
| `config.keycloak.adminPassword` | `{secretName: studio-secrets, secretKey: KEYCLOAK_ADMIN_PASSWORD}` | Admin password. |
| `config.keycloak.realm` | `"rasa-studio"` | Realm. |
| `config.keycloak.apiUsername` | `"realmadmin"` | API user used by the backend. |
| `config.keycloak.apiPassword` | `{secretName: studio-secrets, secretKey: KEYCLOAK_API_PASSWORD}` | API password. |

To use an **external** Keycloak: set `keycloak.enabled: false` and
`config.keycloak.url` to its address. Keycloak stores data in Postgres
(`keycloakDatabaseName`) and is served under `/auth`.

## The `&dns_hostname` anchor (do not break it)

`config.ingressHost` is defined with a YAML anchor (`&dns_hostname`) that other
values reference (`*dns_hostname`), including the bundled rasa subchart's
`/talk` ingress. When generating studio values, **preserve the anchor** — only
change the hostname value, never remove the `&dns_hostname` / `*dns_hostname`
markers.
