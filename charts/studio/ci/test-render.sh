#!/usr/bin/env bash
# Render-time assertions for charts/studio. Needs helm and built dependencies.
set -euo pipefail

chart="$(cd "$(dirname "$0")/.." && pwd)"
failures=0

render() {
  helm template s "$chart" --kube-version 1.31.0 -f "$chart/ci/lint-values.yaml" "$@"
}

check() {
  if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; failures=$((failures + 1)); fi
}

out=$(render --set config.connectionType=https)
base=$(awk '/name: BETTER_AUTH_BASE_URL/ { getline; print $2 }' <<<"$out" | tr -d '"')
check "token issuer equals BETTER_AUTH_BASE_URL + /api/auth" \
  'grep -qx "  STUDIO_TOKEN_ISSUER: \"${base}/api/auth\"" <<<"$out" && [ "$base" = https://studio.example.com ]'
check "JWKS URL points at the in-cluster app service" \
  'grep -qx "  STUDIO_JWKS_URL: \"http://s-studio-app:80/api/auth/jwks\"" <<<"$out"'
check "token audience is the model service" \
  'grep -qx "  STUDIO_TOKEN_AUDIENCE: \"urn:rasa:model-service\"" <<<"$out"'

out=$(render --set global.ingressHost= --set app.ingress.hostName=studio.split.example.com)
check "app.ingress.hostName alone sets the issuer" \
  'grep -qx "  STUDIO_TOKEN_ISSUER: \"http://studio.split.example.com/api/auth\"" <<<"$out"'

check "empty host fails the render with a clear message" \
  '! err=$(render --set global.ingressHost= 2>&1) && grep -q "global.ingressHost or app.ingress.hostName is required" <<<"$err"'
check "empty host renders when rasa is disabled" \
  'render --set global.ingressHost= --set rasa.enabled=false >/dev/null'

out=$(render --set networkPolicy.enabled=true --set networkPolicy.denyAll=true --set rasa.networkPolicy.enabled=true)
check "network policies admit rasa to the app port" \
  'grep -q "name: s-studio-allow-ingress-from-rasa" <<<"$out" && grep -q "name: s-studio-allow-egress-from-rasa" <<<"$out"'

out=$(render --set networkPolicy.enabled=true --set networkPolicy.denyAll=false)
check "no rasa policies when neither side is isolated" \
  '! grep -q "from-rasa" <<<"$out"'

[ "$failures" -eq 0 ] || { echo "$failures check(s) failed"; exit 1; }
