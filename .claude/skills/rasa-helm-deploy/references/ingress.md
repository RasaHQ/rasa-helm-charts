# Ingress

How to detect the cluster's ingress controller and generate the right config
for each chart. All ingress templates use `networking.k8s.io/v1` and the
`service:`/`port:` backend form.

## Detect the controller

```
kubectl get ingressclass
```
The `CONTROLLER` column tells you what's installed:

| Controller value | Ingress class | Typical annotations key prefix |
|------------------|---------------|-------------------------------|
| `k8s.io/ingress-nginx` | `nginx` | `nginx.ingress.kubernetes.io/...` |
| `traefik.io/ingress-controller` | `traefik` | `traefik.ingress.kubernetes.io/...` |
| `ingress.k8s.aws/alb` | `alb` | `alb.ingress.kubernetes.io/...` |
| (none) | — | Ingress won't route; suggest a controller or `LoadBalancer`/`NodePort` service instead |

Set `className` (rasa) / `config.ingressClassName` (studio) to the class name.
If no IngressClass exists, don't enable ingress — offer a `Service` of type
`LoadBalancer` or port-forward for testing instead.

## Per-controller annotation snippets

### nginx
```yaml
annotations:
  nginx.ingress.kubernetes.io/proxy-body-size: "0"
  nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"   # websockets / socketio
  cert-manager.io/cluster-issuer: letsencrypt-prod          # if using cert-manager
```

### traefik
```yaml
annotations:
  traefik.ingress.kubernetes.io/router.entrypoints: websecure
```

### AWS ALB
```yaml
annotations:
  alb.ingress.kubernetes.io/scheme: internet-facing
  alb.ingress.kubernetes.io/target-type: ip
  alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
  alb.ingress.kubernetes.io/certificate-arn: <acm-arn>
```

## TLS

Per-component `tls:` list, each item `{secretName, hosts: [...]}`. With
cert-manager, add the issuer annotation above and cert-manager fills the
secret; otherwise the user provides a TLS secret. Studio's
`config.connectionType: https` affects inter-service URLs — set it when serving
over TLS.

## Chart-specific layout

### rasa
Per-component ingress: `rasa.ingress`, `duckling.ingress`,
`actionServer.ingress`, each with `enabled`, `className`, `annotations`,
`hosts[].paths[]`, `tls`. Default rasa path is `/api`.

**Gotcha:** `global.ingressHost`, when set, overrides the host **only in the
rasa ingress** — `duckling` and `actionServer` ingress templates ignore it and
use their own `.host`. If the user sets `global.ingressHost` and enables
duckling/action-server ingress, set those hosts explicitly too.

### studio
No single global ingress — each web-facing component
(`backend.ingress`, `webClient.ingress`, `keycloak.ingress`) renders its own
Ingress, all bound to the shared `config.ingressHost` (`&dns_hostname` anchor).
Global controls: `config.ingressHost`, `config.ingressAnnotations` (applied to
all), `config.ingressClassName` (applied to all), `config.connectionType`.
Keycloak is served under `/auth`; the bundled rasa model service under `/talk`.

**Gotcha:** preserve the `&dns_hostname` anchor — see `studio-datastores.md`.
Because all components share one host, a single DNS record + one TLS cert
covers the whole Studio install.
