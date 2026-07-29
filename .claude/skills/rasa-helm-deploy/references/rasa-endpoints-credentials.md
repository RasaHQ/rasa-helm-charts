# Rasa: endpoints & credentials

`charts/rasa/` exposes two config maps that most non-expert users find
confusing: `rasa.settings.endpoints` and `rasa.settings.credentials`. Both
default to empty (`{}`) and render into a mounted ConfigMap
(`endpoints.yml` + `credentials.yml`) when
`rasa.settings.mountDefaultConfigmap: true` (default).

> Read the commented examples in `charts/rasa/values.yaml` live for the exact
> current shape. Product concepts below are stable; specific keys may evolve.

## `settings.credentials` — input channels

Defines **how users talk to the assistant** (the connectors). Keys are channel
names; values are that channel's config.

```yaml
rasa:
  settings:
    credentials:
      rest: {}                 # REST channel, no config needed
      # socketio:
      #   user_message_evt: user_uttered
      #   bot_message_evt: bot_uttered
      #   session_persistence: true
```

Common channels: `rest`, `socketio`, plus messaging platforms (facebook,
slack, …) that carry tokens/secrets. Docs:
<https://rasa.com/docs/reference/config/channels/> (or the version's channel
reference). For a first deploy, `rest: {}` is usually enough.

## `settings.endpoints` — backing services

Defines **what the assistant connects to**. Sections:

| Section | Purpose |
|---------|---------|
| `models` | Where to pull the trained model from (`url:`, optional `wait_time_between_pulls`). |
| `action_endpoint` | Custom action server — `url:` (e.g. the in-cluster action-server service) or `actions_module`. |
| `tracker_store` | Where conversations are stored (e.g. `type: redis` with `url/port/db/password/use_ssl`; or `type: sql` Postgres). |
| `event_broker` | Where conversation events are published (e.g. `type: kafka` with `url/security_protocol/sasl_mechanism/sasl_username/sasl_password`). |
| `model_groups` | LLM model groups for LLM-powered features (needs a provider API key env var, e.g. `OPENAI_API_KEY`). |

Example (from a realistic deploy):
```yaml
rasa:
  additionalEnv:
    - name: REDIS_PASSWORD
      valueFrom: { secretKeyRef: { name: redis-secrets, key: password } }
    - name: KAFKA_USER
      valueFrom: { secretKeyRef: { name: kafka-secrets, key: username } }
    - name: KAFKA_PASSWORD
      valueFrom: { secretKeyRef: { name: kafka-secrets, key: password } }
  settings:
    endpoints:
      action_endpoint: { url: "/webhook" }
      tracker_store:
        type: redis
        url: redis-lockstore-master
        port: 6379
        db: 1
        password: ${REDIS_PASSWORD}
      event_broker:
        type: kafka
        url: rasa-kafka-bootstrap.<ns>.svc:9092
        security_protocol: SASL_SSL
        sasl_mechanism: PLAIN
        sasl_username: ${KAFKA_USER}
        sasl_password: ${KAFKA_PASSWORD}
    credentials:
      rest: {}
```

## The `${VAR}` credential rule

**Never put a DB/broker password literally in `endpoints`.** Inject it as an
env var from a Kubernetes Secret via `rasa.additionalEnv`, then reference it as
`${VAR}` inside the endpoint. This keeps secrets out of the values file. (This
is idiom 2 in `secrets.md`.)

## Raw-file escape hatch (GitOps)

`rasa.settings.endpointsRaw` and `rasa.settings.credentialsRaw` accept a raw
YAML **string** that is parsed and **deep-merged** with the structured maps
(structured wins on conflict). Useful for
`helm install --set-file rasa.settings.endpointsRaw=./endpoints.yml` or ArgoCD
multi-source `fileParameters`. Offer this to users who keep endpoint config in
their own repo.
