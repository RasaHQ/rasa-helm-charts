# rasa

A Rasa Pro Helm chart for Kubernetes

![Version: 3.0.0-rc.2](https://img.shields.io/badge/Version-3.0.0--rc.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.20.0-latest](https://img.shields.io/badge/AppVersion-3.20.0--latest-informational?style=flat-square)

## Prerequisites

- Kubernetes 1.30+
- Helm 3.8.0+
- A valid Rasa Pro license key

## Creating Secrets

The chart reads credentials exclusively from Kubernetes Secrets. Only the **license secret is required** to install — all other secrets are optional and only referenced when you enable the corresponding feature.

### License Secret (required)

Create a secret containing your Rasa Pro license key before installing:

```console
kubectl create secret generic rasa-secrets \
  --from-literal=rasaProLicense="<YOUR_LICENSE_KEY>"
```

The chart defaults to `secretName: rasa-secrets` and `secretKey: rasaProLicense`. Override both in your values if you use a different name or key:

```yaml
rasaProLicense:
  secretName: my-custom-secret
  secretKey: myLicenseKey
```

### Optional Secrets

Add optional keys to the same secret (or separate secrets) as you enable features. You can extend the secret you created above:

```console
kubectl patch secret rasa-secrets -p \
  '{"stringData":{"authToken":"<YOUR_TOKEN>","jwtSecret":"<YOUR_JWT_SECRET>"}}'
```

The table below lists all secret-backed fields:

| Secret key | Feature | values.yaml field |
|---|---|---|
| `authToken` | Token-based API authentication | `rasa.settings.authToken` |
| `jwtSecret` | JWT API authentication | `rasa.settings.jwtSecret` |

Both are unset by default, so adding the key to the Secret is not enough on its own — point the values field at it as well:

```yaml
rasa:
  settings:
    authToken:
      secretName: rasa-secrets
      secretKey: authToken
```

Alternatively, create all credentials upfront from a manifest. The chart ships a `secrets.yaml` example that you can use as a starting point — **use `stringData` so Kubernetes base64-encodes the values automatically**:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rasa-secrets
type: Opaque
stringData:
  rasaProLicense: "<YOUR_LICENSE_KEY>"    # required for all deployments
  authToken: "<YOUR_AUTH_TOKEN>"          # optional: token-based API auth
  jwtSecret: "<YOUR_JWT_SECRET>"          # optional: JWT auth
```

## Installing the Chart

Before installing, make sure you have created the license secret as described in [Creating Secrets](#creating-secrets) above.

You can install the chart from either the OCI registry or the GitHub Helm repository.

### Option 1: Install from OCI Registry

To install the chart with the release name `my-release`:

```console
helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version 3.0.0-rc.2
```

### Option 2: Install from GitHub Helm Repository

First, add the Rasa Helm repository:

```console
helm repo add rasa https://helm.rasa.com/charts
helm repo update
```

Then install the chart:

```console
helm install my-release rasa/rasa --version 3.0.0-rc.2
```

## Upgrading the Chart

To upgrade to a new chart version, update the repository index and run:

```console
helm repo update
helm upgrade my-release rasa/rasa --version <new-version> -f values.yaml
```

Or from OCI:

```console
helm upgrade my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa --version <new-version> -f values.yaml
```

> **Note:** Always check the [release notes](https://github.com/RasaHQ/rasa-helm-charts/releases) for breaking changes before upgrading across major versions.

### Upgrading to 3.0.0

**The `actionServer`, `duckling` and `rasaProServices` components have been removed.** This chart now deploys the Rasa Pro server only. Their values keys are ignored rather than rejected, so an existing values file still installs — but nothing reads them.

**Action servers are bring-your-own.** Deploy one yourself and point `rasa.settings.endpoints.action_endpoint.url` at it. If you relied on the chart-managed action server, do this **before** upgrading: the chart still renders and the Rasa Pro pod still starts, so the break only surfaces on the first custom-action call.

**`RASA_DUCKLING_HTTP_URL` is no longer emitted**, and `rasa.settings.ducklingHttpUrl` is gone. Set the variable through `rasa.additionalEnv` if you run Duckling yourself.

**`rasa.settings.authToken` and `rasa.settings.jwtSecret` are now unset by default.** A default install no longer requires `authToken` and `jwtSecret` keys in its Secret — only `rasaProLicense`.

> **Warning:** if you relied on the old defaults without setting these explicitly, this upgrade **removes** `AUTH_TOKEN` and `JWT_SECRET` from the pod and leaves the HTTP API unauthenticated. `rasa.settings.enableApi` still defaults to `true`. Set one of them explicitly before upgrading, or set `rasa.settings.enableApi: false`:
>
> ```yaml
> rasa:
>   settings:
>     authToken:
>       secretName: rasa-secrets
>       secretKey: authToken
> ```
>
> The chart prints an install-time warning whenever the API is enabled with neither set.

Chart 3.0.0 also hardens the surviving `rasa` component to the [restricted Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted).

- `rasa.containerSecurityContext` now defaults to `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`, `runAsNonRoot: true` and `seccompProfile.type: RuntimeDefault`. No `runAsUser` is set, so the effective uid is unchanged and existing model volumes keep their ownership.
- `rasa.automountServiceAccountToken` now defaults to `false`.

**If you override `rasa.image.repository`,** check your image before upgrading. `runAsNonRoot: true` requires a numeric non-root `USER`; the stock image is `USER 1001`. An image that runs as root, or that declares `USER` by name, fails with `CreateContainerConfigError`:

```console
docker image inspect --format '{{.Config.User}}' <your-image>
```

Opt out with `rasa.containerSecurityContext.runAsNonRoot: false`, which leaves the pod outside the restricted standard.

**If you add a sidecar** via `rasa.additionalContainers` or `rasa.initContainers` that calls the Kubernetes API, set `rasa.automountServiceAccountToken: true`.

`Chart.yaml` declares `appVersion` again, tracking the Rasa Pro release the chart targets, and it now appears as the `app.kubernetes.io/version` label on chart-managed objects. `rasa.image.tag` defaults to `""` and falls back to `appVersion`, so **a chart upgrade now moves the Rasa Pro image with it**. Set `rasa.image.tag` to an exact tag to pin the image independently of chart upgrades.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## General Configuration

- **imagePullSecrets**: If you're pulling from a private registry, provide your pull secret name(s) here.
- **rasaProLicense**: All Rasa Pro deployments require a valid license. Provide `secretName` and `secretKey` pointing to the Kubernetes Secret that holds your license value.

> **Note:** For application-specific settings, refer to the [Rasa documentation](https://rasa.com/docs/). The full list of configurable values is at the bottom of this page.

### Minimal Working Configuration

The following is the smallest `values.yaml` needed to get Rasa Pro running. It assumes the license secret was created as shown in [Creating Secrets](#creating-secrets):

```yaml
rasaProLicense:
  secretName: rasa-secrets
  secretKey: rasaProLicense

rasa:
  enabled: true
  image:
    tag: "3.x.x"  # pin to a specific Rasa Pro version
```

Install with:

```console
helm install my-release rasa/rasa -f values.yaml
```

From there, add sections from the rest of this guide as your deployment grows.

### Use MinIO instead of S3

> **Warning:** MinIO is end-of-life and no longer receives updates. The chart still supports connecting to a MinIO instance, but we recommend migrating to S3 or another actively maintained object storage provider.

To use MinIO instead of S3, set `AWS_ENDPOINT_URL` to the URL of the MinIO server and provide `AWS_REGION` and `BUCKET_NAME`. Store your MinIO credentials in a Kubernetes Secret:

```console
kubectl create secret generic minio-credentials \
  --from-literal=accessKey="<YOUR_MINIO_ACCESS_KEY>" \
  --from-literal=secretKey="<YOUR_MINIO_SECRET_KEY>"
```

```yaml
rasa:
  additionalEnv:
    - name: AWS_ENDPOINT_URL
      value: "http://minio.example.com"
    - name: AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          name: minio-credentials
          key: accessKey
    - name: AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: minio-credentials
          key: secretKey
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

### Configuring API Authentication

The Rasa HTTP API supports two authentication methods. Configure one or both via Kubernetes Secrets.

**Token-based authentication:**

```console
kubectl create secret generic rasa-secrets \
  --from-literal=authToken="<YOUR_STATIC_TOKEN>"
```

```yaml
rasa:
  settings:
    authToken:
      secretName: rasa-secrets
      secretKey: authToken
```

**JWT authentication:**

```console
kubectl create secret generic rasa-secrets \
  --from-literal=jwtSecret="<YOUR_JWT_SECRET>"
```

```yaml
rasa:
  settings:
    jwtSecret:
      secretName: rasa-secrets
      secretKey: jwtSecret
    jwtMethod: HS256
```

See the [Rasa documentation](https://rasa.com/docs/reference/api/pro/rasa-pro-rest-api/) for details on API authentication.

### Configuring the Readiness Probe

The default readiness probe hits the `/` endpoint, which returns a success code as soon as the HTTP server is up — before any model has been loaded. For production, use the `/status` endpoint instead, which only returns a success code once Rasa has loaded a model and is ready to process conversations.

**Without authentication:**

```yaml
rasa:
  readinessProbe:
    httpGet:
      path: /status
      port: 5005
      scheme: HTTP
```

**With `authToken` configured:**

When `AUTH_TOKEN` is set, the `/status` endpoint requires authentication. Use an `exec` probe that reads the token from the environment variable:

```yaml
rasa:
  readinessProbe:
    httpGet: null
    exec:
      command:
        - /bin/sh
        - -c
        - "curl -f http://localhost:5005/status?token=${AUTH_TOKEN}"
    initialDelaySeconds: 15
    periodSeconds: 15
    successThreshold: 1
    timeoutSeconds: 5
    failureThreshold: 6
```

> **Note:** The `AUTH_TOKEN` environment variable is automatically injected by the chart from the secret referenced in `rasa.settings.authToken`. Setting `httpGet: null` removes the default value set by the chart — this is required when switching from an `httpGet` probe to an `exec` probe, otherwise both will be rendered and Kubernetes will reject the manifest. Update the URL scheme and port in the `curl` command if you have changed `rasa.settings.scheme` or `rasa.settings.port` from their defaults.

### Graceful Shutdown and Lifecycle Hooks

The `rasa` component accepts a pod-level `terminationGracePeriodSeconds` and a container-level `lifecycle` block. Both are unset by default, so the rendered manifests are unchanged unless you opt in.

When Kubernetes deletes a pod it removes the pod from Service endpoints and sends `SIGTERM` at the same time, so in-flight requests can still arrive for a short window. A `preStop` sleep holds the container open long enough for the endpoint removal to propagate:

```yaml
rasa:
  lifecycle:
    preStop:
      sleep:
        seconds: 10
  terminationGracePeriodSeconds: 60
```

The native `sleep` handler needs no shell or `sleep` binary in the image, which matters for images you do not build yourself. It has been enabled by default since Kubernetes 1.30, the minimum this chart supports, so no feature gate is required. The equivalent `exec` form remains available if you would rather run a real drain command than simply wait:

```yaml
rasa:
  lifecycle:
    preStop:
      exec:
        command: ["/bin/sh", "-c", "sleep 10"]
```

Two rules of thumb when picking values:

- Make the `preStop` sleep at least as long as `readinessProbe.periodSeconds` so load balancers have a full probe cycle to notice the pod is going away.
- Keep `terminationGracePeriodSeconds` larger than the `preStop` duration plus the time your application needs to finish in-flight work. The `preStop` hook runs *inside* the grace period, so a hook longer than the grace period gets cut short by `SIGKILL`.

Leaving `terminationGracePeriodSeconds` unset falls back to the Kubernetes default of 30 seconds.

The `lifecycle` block is passed through verbatim, so any hook handler Kubernetes supports (`exec`, `httpGet`, `sleep`) works. `postStart` is available as well:

```yaml
rasa:
  lifecycle:
    postStart:
      exec:
        command: ["/bin/sh", "-c", "echo rasa pro starting"]
```

> **Note:** The hook applies to the component's main container only. Containers you supply through `initContainers` or `additionalContainers` can carry their own `lifecycle` block directly.

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

#### Sourcing Endpoints and Credentials from Raw YAML Files

In addition to the structured `rasa.settings.endpoints` and `rasa.settings.credentials` maps, the chart accepts the **raw contents of an `endpoints.yml` or `credentials.yml` file** via `rasa.settings.endpointsRaw` and `rasa.settings.credentialsRaw`. This lets the same file the developer uses locally for `rasa train` / `rasa run` flow directly into the rendered ConfigMap with no wrapper file or pre-commit step.

When both the structured and raw values are provided, they are deep-merged. **The structured value wins on key conflicts** — this is intentional so infrastructure-owned blocks (e.g. `tracker_store`, `event_broker`) defined in `rasa.settings.endpoints` override the same keys in the raw file.

Helm CLI (`--set-file`):

```console
helm install my-release oci://europe-west3-docker.pkg.dev/rasa-releases/helm-charts/rasa \
  --version 3.0.0-rc.2 \
  --set-file rasa.settings.endpointsRaw=./endpoints.yml \
  --set-file rasa.settings.credentialsRaw=./credentials.yml
```

ArgoCD multi-source `Application` (referencing files from a values repo):

```yaml
spec:
  sources:
    - repoURL: https://github.com/RasaHQ/rasa-helm-charts
      chart: rasa
      targetRevision: 3.0.0-rc.2
      helm:
        fileParameters:
          - name: rasa.settings.endpointsRaw
            path: $values/endpoints.yml
          - name: rasa.settings.credentialsRaw
            path: $values/credentials.yml
    - repoURL: https://github.com/your-org/your-app-repo
      targetRevision: main
      ref: values
```

`${VAR}` placeholders inside the raw file are preserved verbatim through the parse/merge/render pipeline, so Rasa's runtime environment-variable substitution continues to work.

#### Configuring Endpoints

The `rasa.settings.endpoints` section allows you to configure various endpoints and integrations. These endpoints are written to the `endpoints.yml` file in the ConfigMap.

**Action Server Endpoint:**

This chart does not deploy an action server. Run one yourself and point `action_endpoint.url` at it as a full HTTP URL:

```yaml
rasa:
  settings:
    endpoints:
      action_endpoint:
        url: "http://my-action-server.actions.svc.cluster.local:5055/webhook"
```

Alternatively, run your actions in-process by setting `actions_module` instead of `url`.

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

**Tracker Store (PostgreSQL example):**

```yaml
rasa:
  settings:
    endpoints:
      tracker_store:
        type: sql
        dialect: postgresql
        url: <hostname>
        db: <database>
        username: <username>
        password: <password>
        port: 5432
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

Model groups require an LLM provider API key. Inject it as an environment variable from a Kubernetes Secret:

```console
kubectl create secret generic openai-secret \
  --from-literal=apiKey="<YOUR_OPENAI_API_KEY>"
```

```yaml
rasa:
  additionalEnv:
    - name: OPENAI_API_KEY
      valueFrom:
        secretKeyRef:
          name: openai-secret
          key: apiKey
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

### Environment Variables

Use `additionalEnv` to inject extra environment variables into any component without replacing the chart-managed ones. Both plain values and Secret/ConfigMap references are supported:

```yaml
rasa:
  additionalEnv:
    - name: MY_VAR
      value: "my-value"
    - name: MY_SECRET_VAR
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: my-key
    - name: MY_CONFIGMAP_VAR
      valueFrom:
        configMapKeyRef:
          name: my-configmap
          key: my-key
```

Use `envFrom` to inject all keys from a ConfigMap or Secret as environment variables at once:

```yaml
rasa:
  envFrom:
    - configMapRef:
        name: my-configmap
    - secretRef:
        name: my-secret
```

### Loading Initial Models

Use `initContainers` to download a model before the Rasa server starts. The init container shares the `/app/models` volume with the main container:

```yaml
rasa:
  initContainers:
    - name: load-initial-model
      image: alpine
      command: ["/bin/sh", "-c"]
      args:
        - wget https://my-model-server.example.com/models/model.tar.gz -O /app/models/model.tar.gz
      volumeMounts:
        - mountPath: /app/models
          name: models
```

### Ingress

To expose the Rasa API externally, enable the ingress resource. The example below uses nginx with TLS managed by cert-manager:

```yaml
rasa:
  ingress:
    enabled: true
    className: "nginx"
    annotations:
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
    hosts:
      - host: rasa.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: rasa-tls
        hosts:
          - rasa.example.com
```

#### Shared ingress settings

The `global` block carries three ingress settings so an ingress class, a set of annotations and a host can be declared once instead of being repeated:

```yaml
global:
  ingressClassName: nginx
  ingressAnnotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  ingressHost: rasa.example.com
```

`global.ingressClassName` and `global.ingressAnnotations` are defaults that `rasa.ingress` overrides. A non-empty `rasa.ingress.className` wins outright, and `rasa.ingress.annotations` wins per key while non-conflicting global annotations still merge in.

> **Note:** `global.ingressHost` behaves differently. It overrides `rasa.ingress.hosts[*].host` instead of falling back to it, so leave it unset if you need per-host values.

`global.ingressHost` sets the ingress rule host and nothing else. TLS is a separate list that the chart does not derive from it, so a single-host deployment repeats the hostname under `rasa.ingress.tls`:

```yaml
global:
  ingressHost: rasa.example.com
rasa:
  ingress:
    tls:
      - secretName: rasa-tls
        hosts:
          - rasa.example.com
```

Keep the two in sync. If `global.ingressHost` changes and `rasa.ingress.tls[*].hosts` is left behind, the chart still renders and applies without complaint: the ingress serves the new host while the TLS section claims the old one, so the controller finds no certificate matching the host it serves and falls back to its default. The symptom is a browser certificate warning rather than a Helm error, which makes it easy to miss.

Because Helm propagates `global` down the dependency tree after user overrides are merged, a parent chart that bundles this one can set these under its own `global` block and have them reach this chart. That is how Rasa Studio drives the host of the model-service ingress.

### Resources and Autoscaling

No resource requests or limits are set by default. For production, always set these explicitly:

```yaml
rasa:
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 2
      memory: 4Gi
```

Enable Horizontal Pod Autoscaling (HPA) to scale replicas based on CPU or memory:

```yaml
rasa:
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    # targetMemoryUtilizationPercentage: 80
```

### Pod Topology Spread Constraints

Once a component runs more than one replica, spread its pods across failure domains so a single zone or node outage cannot take all of them down:

```yaml
rasa:
  replicaCount: 3
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: ScheduleAnyway
```

A constraint needs a `labelSelector` to decide which pods to count, and one that selects nothing is silently ignored rather than rejected. The chart therefore fills in the component's own selector labels whenever an entry omits `labelSelector`, so the example above means "spread the Rasa Pro server pods across zones" without further configuration. Set `labelSelector` yourself when you want to count a broader set of pods than the one component.

Choose `whenUnsatisfiable` to match the replica count: `DoNotSchedule` gives the Rasa Pro server a hard spread guarantee at three or more replicas, but at one or two it leaves pods `Pending` when a zone has no room. Prefer `ScheduleAnyway` there, or leave the list empty, since a spread constraint over a single replica does nothing.

#### Setting labelSelector explicitly

A `labelSelector` selects pods, so it can only match labels the pod template actually carries. The chart labels its pods with `app.kubernetes.io/name` and `app.kubernetes.io/instance` (the release name), plus anything added through the chart-level `podLabels`. The selector injected by default is exactly that first pair, which is also what the Deployment uses in `spec.selector.matchLabels` to own its pods.

Labels set through `deploymentLabels` or `global.additionalDeploymentLabels` are attached to the Deployment object rather than to the pods, as are `helm.sh/chart` and `app.kubernetes.io/managed-by`. A selector referring to any of those matches no pods, and the constraint is then quietly ignored.

Writing the selector out explicitly is the same as the default, and is worth doing when you need several constraints with different scopes:

```yaml
rasa:
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: DoNotSchedule
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: my-release-rasa
          app.kubernetes.io/instance: my-release
```

To spread the Rasa Pro server together with a workload this chart does not manage — your own action server, for instance — as a single pool rather than each on its own, give both sets of pods a shared label and select on it. `podLabels` applies to the pods this chart creates; label the other workload the same way in its own chart:

```yaml
podLabels:
  rasa.com/spread-group: rasa-stack

rasa:
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          rasa.com/spread-group: rasa-stack
```

A shared `podLabels` key is preferable to selecting on `app.kubernetes.io/instance` for this. The selector cannot be templated, so the release name would have to be spelled out, and when this chart is deployed as a Rasa Studio subchart the Studio components share the same `app.kubernetes.io/instance` value and would be drawn into the same spread group.

`matchExpressions` is also available, which is the shorter route to pooling a named subset without introducing a new label:

```yaml
      labelSelector:
        matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
              - my-release-rasa
              - my-action-server
```

### Network Policies

Network policies are disabled by default. Enable them to restrict traffic to and from the Rasa Pro server:

```yaml
networkPolicy:
  enabled: true
  denyAll: true
  nodeCIDR:
    - ipBlock:
        cidr: 10.0.0.0/8  # adjust to your node CIDR
```

> **Note:** When `networkPolicy.denyAll` is true, you must supply `nodeCIDR` so that the kubelet can reach pods for liveness and readiness probes.

## Configuration Reference

The following table lists all configurable parameters for this chart and their default values.

## Values

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| deploymentAnnotations | object | deploymentAnnotations defines annotations to add to all Rasa deployments | `{}` |
| deploymentLabels | object | deploymentLabels defines labels to add to all Rasa deployment | `{}` |
| dnsConfig | object | dnsConfig specifies Pod's DNS config # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config | `{}` |
| dnsPolicy | string | dnsPolicy specifies Pod's DNS policy # ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy | `""` |
| fullnameOverride | string | fullnameOverride overrides the fully-qualified name prefix used for all chart resources. | `""` |
| global.additionalDeploymentLabels | object | global.additionalDeploymentLabels adds extra labels to all Deployment resources. Useful for mapping organizational structures onto Kubernetes objects. See: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ | `{}` |
| global.ingressAnnotations | object | global.ingressAnnotations defines annotations added to the Rasa Pro server ingress. Merged with rasa.ingress.annotations, which wins on key conflicts. Applies only to the rasa component. | `{}` |
| global.ingressClassName | string | global.ingressClassName defines the ingress class for the Rasa Pro server ingress. Used only when rasa.ingress.className is empty. Applies only to the rasa component. | `""` |
| global.ingressHost | string | global.ingressHost sets the host of every rule in the Rasa Pro server ingress. Unlike the other global ingress settings it overrides rasa.ingress.hosts[*].host rather than acting as a fallback. Applies only to the rasa component. | `nil` |
| hostAliases | list | hostAliases specifies pod-level override of hostname resolution when DNS and other options are not applicable | `[]` |
| hostNetwork | bool | hostNetwork controls whether the pod may use the node network namespace | `false` |
| imagePullSecrets | list | imagePullSecrets contains references to Secrets for pulling images from private registries. | `[]` |
| nameOverride | string | nameOverride overrides the name used for chart resources. Defaults to the chart name. | `""` |
| networkPolicy.denyAll | bool | networkPolicy.denyAll applies a default-deny NetworkPolicy that blocks all ingress and egress traffic before more specific rules are applied. | `false` |
| networkPolicy.enabled | bool | networkPolicy.enabled enables Kubernetes NetworkPolicy resources for the Rasa Pro server. When true, only explicitly allowed traffic is permitted. | `false` |
| networkPolicy.nodeCIDR | list | networkPolicy.nodeCIDR specifies node IP ranges allowed to reach pods. Required to allow kubelet liveness and readiness probes when networkPolicy.enabled is true. | `[]` |
| podLabels | object | podLabels defines labels to add to all Rasa pod(s) | `{}` |
| rasa.additionalArgs | list | rasa.additionalArgs adds additional arguments to the default args | `[]` |
| rasa.additionalContainers | list | rasa.additionalContainers allows to specify additional containers for the Rasa Deployment | `[]` |
| rasa.additionalEnv | list | rasa.additionalEnv adds additional environment variables | `[]` |
| rasa.affinity | object | rasa.affinity allows the deployment to schedule using affinity rules # Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity | `{}` |
| rasa.args | list | rasa.args overrides the default arguments for the container | `[]` |
| rasa.automountServiceAccountToken | bool | rasa.automountServiceAccountToken determines whether the Rasa Pro pod is given a Kubernetes API token at /var/run/secrets/kubernetes.io/serviceaccount. Rasa Pro never calls the Kubernetes API and this chart grants no RBAC, so the token is left out. Set it to true if you add a sidecar via rasa.additionalContainers that needs one. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ | `false` |
| rasa.autoscaling.enabled | bool | autoscaling.enabled specifies whether autoscaling should be enabled | `false` |
| rasa.autoscaling.maxReplicas | int | autoscaling.maxReplicas specifies the maximum number of replicas | `100` |
| rasa.autoscaling.minReplicas | int | autoscaling.minReplicas specifies the minimum number of replicas | `1` |
| rasa.autoscaling.targetCPUUtilizationPercentage | int | autoscaling.targetCPUUtilizationPercentage specifies the target CPU/Memory utilization percentage | `80` |
| rasa.command | list | rasa.command overrides the default command for the container | `[]` |
| rasa.containerSecurityContext | object | rasa.containerSecurityContext defines security context that allows you to overwrite the container-level security context The defaults below satisfy the restricted Pod Security Standard. Ref: https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` |
| rasa.containerSecurityContext.allowPrivilegeEscalation | bool | rasa.containerSecurityContext.allowPrivilegeEscalation determines whether to allow privilege escalation. | `false` |
| rasa.containerSecurityContext.capabilities | object | rasa.containerSecurityContext.capabilities defines the Linux capabilities configuration. | `{"drop":["ALL"]}` |
| rasa.containerSecurityContext.capabilities.drop | list | rasa.containerSecurityContext.capabilities.drop defines capabilities to drop from the container. | `["ALL"]` |
| rasa.containerSecurityContext.runAsNonRoot | bool | rasa.containerSecurityContext.runAsNonRoot determines whether to run the container as a non-root user. REQUIRES an image whose USER is a numeric non-root uid. The stock rasa-pro image is USER 1001 and satisfies this. If you point rasa.image.repository at a custom image that runs as root, or whose USER is a name rather than a number, the pod will fail with CreateContainerConfigError. Fix the image, or set this to false — in which case the deployment will not satisfy the restricted Pod Security Standard. | `true` |
| rasa.containerSecurityContext.seccompProfile | object | rasa.containerSecurityContext.seccompProfile defines the seccomp profile configuration. | `{"type":"RuntimeDefault"}` |
| rasa.containerSecurityContext.seccompProfile.type | string | rasa.containerSecurityContext.seccompProfile.type is the seccomp profile type. | `"RuntimeDefault"` |
| rasa.enabled | bool | rasa.enabled enables the Rasa Pro server deployment. | `true` |
| rasa.envFrom | list | rasa.envFrom is used to add environment variables from ConfigMap or Secret | `[]` |
| rasa.image.pullPolicy | string | image.pullPolicy specifies image pull policy | `"IfNotPresent"` |
| rasa.image.repository | string | image.repository specifies image repository | `"europe-west3-docker.pkg.dev/rasa-releases/rasa-pro/rasa-pro"` |
| rasa.image.tag | string | image.tag overrides the Rasa Pro image tag. Empty (default) uses the chart's appVersion. Set an exact, immutable tag to pin deployments independently of chart upgrades. | `""` |
| rasa.ingress.annotations | object | ingress.annotations defines annotations to add to the ingress | `{}` |
| rasa.ingress.className | string | ingress.className specifies the ingress className to be used | `""` |
| rasa.ingress.enabled | bool | ingress.enabled specifies whether an ingress service should be created | `false` |
| rasa.ingress.hosts | list | ingress.hosts specifies the hosts for this ingress | `[{"extraPaths":[],"host":"INGRESS.HOST.NAME","paths":[{"path":"/api","pathType":"Prefix"}]}]` |
| rasa.ingress.labels | object | ingress.labels defines labels to add to the ingress | `{}` |
| rasa.ingress.tls | list | ingress.tls specifies the TLS configuration for ingress. Not derived from global.ingressHost. List every host explicitly and keep it in sync with ingress.hosts, otherwise the ingress serves a host the certificate does not cover. | `[]` |
| rasa.initContainers | list | rasa.initContainers allows to specify init containers for the Rasa deployment # Ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ # <PATH_TO_INITIAL_MODEL> has to be a URL (without auth) that points to a tar.gz file | `[]` |
| rasa.lifecycle | object | rasa.lifecycle defines container lifecycle hooks (postStart / preStop) for the Rasa container # Ref: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/ | `{}` |
| rasa.livenessProbe.enabled | bool | livenessProbe.enabled is used to enable or disable liveness probe | `true` |
| rasa.livenessProbe.failureThreshold | int | livenessProbe.failureThreshold defines after how many failures container is considered unhealthy | `6` |
| rasa.livenessProbe.httpGet | object | livenessProbe.httpGet is used to define HTTP request | `{"path":"/","port":5005,"scheme":"HTTP"}` |
| rasa.livenessProbe.initialDelaySeconds | int | livenessProbe.initialDelaySeconds defines wait time in seconds before performing the first probe | `15` |
| rasa.livenessProbe.periodSeconds | int | livenessProbe.periodSeconds specifies that the kubelet should perform a liveness probe every X seconds | `15` |
| rasa.livenessProbe.successThreshold | int | livenessProbe.successThreshold is the minimum consecutive successes required before the probe is considered successful after a failure | `1` |
| rasa.livenessProbe.terminationGracePeriodSeconds | int | livenessProbe.terminationGracePeriodSeconds is an optional duration in seconds the pod needs to terminate gracefully after a liveness probe failure | `30` |
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
| rasa.readinessProbe.successThreshold | int | readinessProbe.successThreshold is the minimum consecutive successes required before the probe is considered successful after a failure | `1` |
| rasa.readinessProbe.timeoutSeconds | int | readinessProbe.timeoutSeconds defines number of seconds after which the probe times out | `5` |
| rasa.replicaCount | int | rasa.replicaCount specifies number of replicas | `1` |
| rasa.resources | object | rasa.resources specifies the resources limits and requests | `{}` |
| rasa.service | object | rasa.service configures the Kubernetes Service exposing the Rasa Pro server. | `{"annotations":{},"externalTrafficPolicy":"Cluster","loadBalancerIP":null,"nodePort":null,"port":5005,"targetPort":5005,"type":"ClusterIP"}` |
| rasa.service.annotations | object | service.annotations defines annotations to add to the service | `{}` |
| rasa.service.externalTrafficPolicy | string | service.externalTrafficPolicy enables client source IP preservation # Ref: http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip | `"Cluster"` |
| rasa.service.loadBalancerIP | string | service.loadBalancerIP exposes the Service externally using a cloud provider's load balancer # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer | `nil` |
| rasa.service.nodePort | string | service.nodePort is used to specify the nodePort(s) value(s) for the LoadBalancer and NodePort service types # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#nodeport | `nil` |
| rasa.service.port | int | service.port is used to specify service port | `5005` |
| rasa.service.targetPort | int | service.targetPort is the container port that Service traffic is forwarded to. Should match settings.port. | `5005` |
| rasa.service.type | string | service.type is used to specify service type | `"ClusterIP"` |
| rasa.serviceAccount | object | rasa.serviceAccount defines service account | `{"annotations":{},"create":true,"name":""}` |
| rasa.serviceAccount.annotations | object | serviceAccount.annotations defines annotations to add to the service account | `{}` |
| rasa.serviceAccount.create | bool | serviceAccount.create specifies whether a service account should be created | `true` |
| rasa.serviceAccount.name | string | serviceAccount.name is the name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""` |
| rasa.settings.authToken | string | settings.authToken references the Kubernetes Secret containing the static bearer token used to authenticate API requests. Unset by default: with settings.enableApi true and neither authToken nor jwtSecret set, the HTTP API accepts unauthenticated requests. | `nil` |
| rasa.settings.cors | string | settings.cors sets the allowed CORS origin for the Rasa API. Defaults to '*' (all origins). Restrict to specific domains in production. | `"*"` |
| rasa.settings.credentials | object | settings.credentials enables credentials configuration for channel connectors # See: https://rasa.com/docs/reference/channels/messaging-and-voice-channels | `{}` |
| rasa.settings.credentialsRaw | string | settings.credentialsRaw accepts a raw YAML string (e.g. the contents of a credentials.yml file) that is parsed and deep-merged with settings.credentials. The structured value wins on key conflicts. Intended for `helm install --set-file rasa.settings.credentialsRaw=./credentials.yml` or ArgoCD multi-source `fileParameters` referencing `$values/credentials.yml`. Leave unset/empty to disable. Malformed YAML fails the template render. | `""` |
| rasa.settings.debugMode | bool | settings.debugMode enables debug mode | `false` |
| rasa.settings.enableApi | bool | settings.enableApi enables the Rasa HTTP API in addition to the configured input channel. Required for most integrations. Supports token-based auth (authToken) or JWT auth (jwtSecret + jwtMethod). | `true` |
| rasa.settings.endpoints | object | settings.endpoints enables endpoints configuration for the Rasa deployment. See: https://rasa.com/docs/pro/build/configuring-assistant#endpoints | `{}` |
| rasa.settings.endpointsRaw | string | settings.endpointsRaw accepts a raw YAML string (e.g. the contents of an endpoints.yml file) that is parsed and deep-merged with settings.endpoints. The structured value wins on key conflicts, so infra-owned blocks (tracker_store, event_broker) defined in settings.endpoints take precedence over the same keys in the raw file. Intended for `helm install --set-file rasa.settings.endpointsRaw=./endpoints.yml` or ArgoCD multi-source `fileParameters` referencing `$values/endpoints.yml`. Leave unset/empty to disable. Malformed YAML fails the template render. | `""` |
| rasa.settings.environment | string | settings.environment sets the Rasa runtime environment. Use 'production' to disable certain development-only defaults. | `"development"` |
| rasa.settings.jwtMethod | string | settings.jwtMethod is JWT algorithm to be used | `"HS256"` |
| rasa.settings.jwtSecret | string | settings.jwtSecret references the Kubernetes Secret containing the JWT secret used to verify signed tokens for API authentication. Unset by default. Set this together with settings.jwtMethod to authenticate API requests with signed JWTs instead of a static token. | `nil` |
| rasa.settings.logging.logLevel | string | logging.logLevel is Rasa Log Level | `"info"` |
| rasa.settings.mountDefaultConfigmap | bool | settings.mountDefaultConfigmap controls whether the chart mounts a ConfigMap containing credentials.yml and endpoints.yml into the Rasa container. When false, credentials and endpoints must be available at /.config or baked into the image. | `true` |
| rasa.settings.mountModelsVolume | bool | settings.mountModelsVolume controls whether the chart mounts a volume for Rasa models at /app/models. When false, models must be available at /app/models or baked into the image. | `true` |
| rasa.settings.port | int | settings.port defines port on which Rasa runs | `5005` |
| rasa.settings.scheme | string | settings.scheme defines scheme by which the service are accessible | `"http"` |
| rasa.settings.telemetry.debug | bool | telemetry.debug prints telemetry data to stdout | `false` |
| rasa.settings.telemetry.enabled | bool | telemetry.enabled allow Rasa to collect anonymous usage details | `true` |
| rasa.settings.useDefaultArgs | bool | settings.useDefaultArgs controls whether the chart injects default Rasa startup arguments. Keep true for standalone Rasa Pro deployments. Only disable when deploying as part of Rasa Studio. | `true` |
| rasa.strategy | object | rasa.strategy specifies deployment strategy type # ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy | `{}` |
| rasa.terminationGracePeriodSeconds | int | rasa.terminationGracePeriodSeconds is the pod-level grace period Kubernetes waits after SIGTERM before sending SIGKILL. Leave unset to use the Kubernetes default of 30 | `nil` |
| rasa.tolerations | list | rasa.tolerations defines tolerations for pod assignment # Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ | `[]` |
| rasa.topologySpreadConstraints | list | rasa.topologySpreadConstraints controls how pods are spread across topology domains such as zones or nodes. An entry that omits labelSelector defaults to this component's own pods. # Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/ | `[]` |
| rasa.volumeMounts | list | rasa.volumeMounts specifies additional volumes to mount in the Rasa container | `[]` |
| rasa.volumes | list | rasa.volumes specify additional volumes to mount in the Rasa container # Ref: https://kubernetes.io/docs/concepts/storage/volumes/ | `[]` |
| rasaProLicense | object | rasaProLicense references the Kubernetes Secret that holds your Rasa Pro license key. Required for all Rasa Pro deployments. | `{"secretKey":"rasaProLicense","secretName":"rasa-secrets"}` |
