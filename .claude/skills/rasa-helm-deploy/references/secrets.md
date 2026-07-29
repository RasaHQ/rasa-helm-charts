# Secrets & credentials

How the Rasa charts consume credentials, the default secret-key inventory per
chart, and the "beyond-default" env-var catalog for features whose secrets are
**not** in the chart's `secrets.yaml`.

> Always read `charts/<chart>/secrets.yaml` live for the current default keys —
> the inventory below is a guide, not a substitute.

## The credential-injection idioms

There are three shapes in these charts. Route each credential to the right one.

1. **Schema-validated secretRef object** — `{secretName, secretKey}`.
   Used for first-class credentials the chart wires directly. Validated by
   `values.schema.json` (`definitions.secretRef` requires both fields,
   non-empty).
   ```yaml
   rasaProLicense: { secretName: rasa-secrets, secretKey: rasaProLicense }
   config.database.password: { secretName: studio-secrets, secretKey: DATABASE_PASSWORD }
   ```

2. **Env-var interpolation** — `additionalEnv` + `${VAR}`.
   Used for rasa **endpoint** credentials (tracker store / event broker DB and
   broker passwords). You inject the value as an env var sourced from a K8s
   secret, then reference `${VAR}` inside `settings.endpoints`.
   ```yaml
   rasa:
     additionalEnv:
       - name: KAFKA_PASSWORD
         valueFrom: { secretKeyRef: { name: kafka-secrets, key: password } }
     settings:
       endpoints:
         event_broker: { type: kafka, sasl_password: ${KAFKA_PASSWORD}, ... }
   ```

3. **Raw env `secret: {name, key}`** — used by Studio's `backend` /
   `eventIngestion` env-var blocks (note: `name`/`key`, not
   `secretName`/`secretKey`), and `rasa.*.overrideEnv` uses raw Kubernetes
   `valueFrom.secretKeyRef: {name, key}`.
   ```yaml
   eventIngestion:
     environmentVariables:
       KAFKA_SASL_PASSWORD: { secret: { name: studio-secrets, key: KAFKA_SASL_PASSWORD } }
   ```

**Important:** studio has **no** JWT / session / encryption secret — do not
invent one. Keys named `*_SECRET_KEY` in `studio-secrets` are just the *names*
of the license / OpenAI keys, not signing material.

## Default secret-key inventory

Create these with `kubectl create secret generic <name> --from-literal=...`
(use `stringData:` if writing a manifest, so values are auto-base64-encoded).

### rasa — default secret `rasa-secrets`

| Key | Required? | Feature | values.yaml field |
|-----|-----------|---------|-------------------|
| `rasaProLicense` | **required** (ask user) | Rasa Pro license (all deployments) | `rasaProLicense` |
| `authToken` | **required — auto-generate** | Token-based API auth | `rasa.settings.authToken` |
| `jwtSecret` | **required — auto-generate** | JWT API auth | `rasa.settings.jwtSecret` |
| `kafkaSslPassword` | optional | Kafka SASL password (rasa-pro-services, non-IAM) | `rasaProServices.kafka.saslPassword` |
| `analyticsDbUrl` | optional | Analytics DB URL (rasa-pro-services, non-IAM) | `rasaProServices.database.urlExistingSecretName` |

**`authToken` and `jwtSecret` are effectively required**: the chart's default
`values.yaml` wires `rasa.settings.authToken`/`jwtSecret` to
`rasa-secrets/authToken` and `rasa-secrets/jwtSecret`, so the secret must
contain them or the pod fails to start. **Do not ask the user for these —
generate them** (12-char alphanumeric, no special characters) and include them
in the `kubectl create secret` command / placeholder manifest. Only the license
comes from the user.

Rasa images and charts are **public** — no image-pull credentials are required
by default; `imagePullSecrets` are optional and only needed if the customer
mirrors images to their own private registry.

### studio — default secret `studio-secrets`

| Key | Required? | Purpose | Reference shape |
|-----|-----------|---------|-----------------|
| `DATABASE_PASSWORD` | **required** | Postgres password (backend + Keycloak DB) | `config.database.password` → `{secretName, secretKey}` |
| `KEYCLOAK_ADMIN_PASSWORD` | **required** | Keycloak admin console | `config.keycloak.adminPassword` → `{secretName, secretKey}` |
| `KEYCLOAK_API_PASSWORD` | **required** | Keycloak API (realmadmin) used by backend | `config.keycloak.apiPassword` → `{secretName, secretKey}` |
| `RASA_PRO_LICENSE_SECRET_KEY` | **required** | Rasa Pro license (bundled rasa model service) | `rasa.rasa.overrideEnv` → `valueFrom.secretKeyRef {name,key}` |
| `OPENAI_API_KEY_SECRET_KEY` | **required** | OpenAI key for LLM features | `rasa.rasa.overrideEnv` → `valueFrom.secretKeyRef {name,key}` |
| `KAFKA_SASL_PASSWORD` | required if `eventIngestion.enabled` | Kafka SASL password | `eventIngestion.environmentVariables.KAFKA_SASL_PASSWORD.secret {name,key}` |

If the secret is renamed from the default, **every** `secretName`/`name` field
that points at it must be overridden in values.

## Beyond-default env-var catalog

Depending on product configuration, users need env vars/secrets **not** in the
chart's `secrets.yaml`. Consult the authoritative docs and wire the extra key
via idiom 2 or 3 above (`additionalEnv` for rasa; `environmentVariables` /
`overrideEnv` for studio components).

- Rasa: <https://rasa.com/docs/reference/config/environment-variables/>
- Studio: <https://rasa.com/docs/reference/config/studio-environment-variables/>

Common extras and where they come from:

| Feature | Env var(s) | Secret? | Notes |
|---------|-----------|---------|-------|
| Rasa license (env form) | `RASA_LICENSE` | yes | Docs use `RASA_LICENSE`; the chart wires the license as `rasaProLicense`/`RASA_PRO_LICENSE`. Reconcile to the chart's key. |
| Non-OpenAI LLM providers | `AZURE_OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `COHERE_API_KEY`, etc. | yes | Needed when `model_groups` uses a non-OpenAI provider. Add to secret + `additionalEnv`. |
| Secret manager integration | `SECRET_MANAGER` (default `vault`) + Vault creds | mixed | For externalized secrets via Vault. |
| RabbitMQ event broker (TLS) | `RABBITMQ_SSL_CLIENT_CERTIFICATE`, `RABBITMQ_SSL_CLIENT_KEY`, `RASA_ENVIRONMENT` | cert/key as files | Mount cert/key; reference paths. |
| SQL tracker store tuning | `POSTGRESQL_SCHEMA`, `POSTGRESQL_POOL_SIZE`, `POSTGRESQL_MAX_OVERFLOW` | no | Plain env, not secrets. |

When you add any extra secret key, remember to (a) include it in the
`kubectl create secret` command / placeholder manifest, and (b) add the
`valueFrom.secretKeyRef` env entry so the container receives it — the chart
will not wire an unknown key for you.
