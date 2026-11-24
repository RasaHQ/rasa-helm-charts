#!/usr/bin/env bash
# Render-time assertions for charts/studio. Needs helm and built dependencies.
set -euo pipefail

chart="$(cd "$(dirname "$0")/.." && pwd)"
failures=0

render() {
  helm template s "$chart" --kube-version 1.37.0 -f "$chart/ci/lint-values.yaml" "$@"
}

check() {
  if eval "$2"; then echo "ok   - $1"; else echo "FAIL - $1"; failures=$((failures + 1)); fi
}

out=$(render --set config.connectionType=https)
base=$(awk '/name: BETTER_AUTH_BASE_URL/ { getline; print $2 }' <<<"$out" | tr -d '"')
check "token issuer equals BETTER_AUTH_BASE_URL + /api/auth" \
  'grep -qx "  STUDIO_TOKEN_ISSUER: \"${base}/api/auth\"" <<<"$out" && [ "$base" = https://studio.example.com ]'
check "auth URL points at the in-cluster app service" \
  'grep -qx "  STUDIO_AUTH_URL: \"http://s-studio-app:80\"" <<<"$out"'
check "JWKS URL and audience are left to the model service's defaults" \
  '! grep -qE "STUDIO_(JWKS_URL|TOKEN_AUDIENCE)" <<<"$out"'

out=$(render --set global.ingressHost= --set app.ingress.hostName=studio.split.example.com)
check "app.ingress.hostName alone sets the issuer" \
  'grep -qx "  STUDIO_TOKEN_ISSUER: \"http://studio.split.example.com/api/auth\"" <<<"$out"'

check "empty host fails the render with a clear message" \
  '! err=$(render --set global.ingressHost= 2>&1) && grep -q "global.ingressHost or app.ingress.hostName is required" <<<"$err"'
check "empty host fails the render when rasa is disabled" \
  '! render --set global.ingressHost= --set rasa.enabled=false >/dev/null 2>&1'
check "empty host renders when app.env sets BETTER_AUTH_BASE_URL" \
  'render --set global.ingressHost= --set "app.env[0].name=BETTER_AUTH_BASE_URL,app.env[0].value=https://pub.example.com" >/dev/null'

out=$(render --set "app.env[0].name=BETTER_AUTH_BASE_URL,app.env[0].value=https://pub.example.com/")
check "app.env BETTER_AUTH_BASE_URL is set once and sets the issuer" \
  '[ "$(grep -c "name: BETTER_AUTH_BASE_URL" <<<"$out")" -eq 1 ] && grep -qx "  STUDIO_TOKEN_ISSUER: \"https://pub.example.com/api/auth\"" <<<"$out"'

out=$(render \
  --set "rasa.overrideEnv[0].name=RASA_LICENSE,rasa.overrideEnv[0].value=x" \
  --set "rasa.overrideEnv[1].name=OPENAI_API_KEY,rasa.overrideEnv[1].value=x" \
  --set "rasa.overrideEnv[2].name=STUDIO_TOKEN_ISSUER,rasa.overrideEnv[2].value=https://i.example.com/api/auth" \
  --set "rasa.overrideEnv[3].name=STUDIO_AUTH_URL,rasa.overrideEnv[3].value=http://a.example.com")
rasapro=$(awk '/^# Source: studio\/charts\/rasa\/templates\/deployment.yaml/,/^---/' <<<"$out")
check "rasa.overrideEnv token settings sit in env, which wins over the envFrom ConfigMap" \
  '[ "$(grep -cE "name: STUDIO_(TOKEN_ISSUER|AUTH_URL)$" <<<"$rasapro")" -eq 2 ] && grep -q "name: shared-environment" <<<"$rasapro"'

out=$(render --set networkPolicy.enabled=true --set networkPolicy.denyAll=true --set rasa.networkPolicy.enabled=true)
check "network policies admit rasa to the app port" \
  'grep -q "name: s-studio-allow-ingress-from-rasa" <<<"$out" && grep -q "name: s-studio-allow-egress-from-rasa" <<<"$out"'

out=$(render --set networkPolicy.enabled=true --set networkPolicy.denyAll=false)
check "no rasa policies when neither side is isolated" \
  '! grep -q "from-rasa" <<<"$out"'

out=$(render)
check "app container gets the in-cluster model service URL" \
  'grep -A1 "name: MS_API_URL" <<<"$out" | grep -qx "              value: \"http://rasapro:80\""'
check "config.js turns on the model service and not Copilot" \
  'grep -qx "    window.MODEL_SERVICE_ENABLED = \"true\";" <<<"$out" && grep -qx "    window.COPILOT_ENABLED = \"false\";" <<<"$out"'
check "config.js keeps window.MS_API_URL for the preview" \
  'grep -q "    window.MS_API_URL = \"http://studio.example.com\";" <<<"$out"'

out=$(render --set rasa.enabled=false)
check "no MS_API_URL and model service off without rasa" \
  '! grep -q "name: MS_API_URL" <<<"$out" && grep -qx "    window.MODEL_SERVICE_ENABLED = \"false\";" <<<"$out"'

out=$(render --set rasa.enabled=false \
  --set 'app.env[0].name=MS_API_URL,app.env[0].value=http://ms:8000' \
  --set 'app.env[1].name=COPILOT_API_URL,app.env[1].value=http://copilot:5050')
check "app.env URLs turn on both flags" \
  'grep -qx "    window.MODEL_SERVICE_ENABLED = \"true\";" <<<"$out" && grep -qx "    window.COPILOT_ENABLED = \"true\";" <<<"$out"'

out=$(render --set 'app.env[0].name=MS_API_URL,app.env[0].value=http://ms:8000')
check "app.env MS_API_URL replaces the chart default" \
  '[ "$(grep -c "name: MS_API_URL" <<<"$out")" -eq 1 ] && grep -A1 "name: MS_API_URL" <<<"$out" | grep -q "http://ms:8000"'

out=$(render --set app.webClient.config.COPILOT_ENABLED=true)
check "app.webClient.config overrides a flag" \
  'grep -qx "    window.COPILOT_ENABLED = \"true\";" <<<"$out"'

out=$(render --set networkPolicy.enabled=true --set rasa.networkPolicy.enabled=true --set rasa.networkPolicy.denyAll=true)
check "network policies admit the app to rasa port 8000" \
  'grep -q "name: s-studio-allow-egress-to-rasa" <<<"$out" && grep -q "name: s-studio-allow-ingress-to-rasa" <<<"$out" && grep -A20 "name: s-studio-allow-ingress-to-rasa" <<<"$out" | grep -q "port: 8000"'

out=$(render --set networkPolicy.enabled=true --set rasa.networkPolicy.enabled=true)
check "no rasa ingress policy while rasa ingress is open" \
  '! grep -q "allow-ingress-to-rasa" <<<"$out"'

out=$(render --set networkPolicy.enabled=true --set rasa.networkPolicy.enabled=true \
  --set "rasa.networkPolicy.allowIngressFrom[0].namespaceSelector.matchLabels.x=y")
check "rasa allowIngressFrom alone still admits the app to rasa" \
  'grep -q "name: s-studio-allow-ingress-to-rasa" <<<"$out"'

out=$(render --set rasa.fullnameOverride=)
check "empty rasa.fullnameOverride points MS_API_URL at the subchart service" \
  'grep -A1 "name: MS_API_URL" <<<"$out" | grep -q "http://s-rasa:80" && grep -A3 "^kind: Service$" <<<"$out" | grep -qx "  name: s-rasa"'

out=$(render --set "app.env[0].name=COPILOT_API_URL,app.env[0].value=" --set "app.env[1].name=MS_API_URL,app.env[1].value=")
check "empty app.env URLs turn both flags off" \
  'grep -qx "    window.MODEL_SERVICE_ENABLED = \"false\";" <<<"$out" && grep -qx "    window.COPILOT_ENABLED = \"false\";" <<<"$out" && [ "$(grep -c "name: MS_API_URL" <<<"$out")" -eq 1 ]'

out=$(render --set "app.env[0].name=COPILOT_API_URL,app.env[0].valueFrom.secretKeyRef.name=s,app.env[0].valueFrom.secretKeyRef.key=k")
check "a valueFrom URL turns its flag on" \
  'grep -qx "    window.COPILOT_ENABLED = \"true\";" <<<"$out"'

out=$(render --set app.encryptionKey.secretName=my-secrets --set app.encryptionKey.secretKey=KEK)
check "app container reads STUDIO_ENCRYPTION_KEY from the configured Secret" \
  'grep -A4 "name: STUDIO_ENCRYPTION_KEY" <<<"$out" | tr -d " " | tr "\n" "|" | grep -q "secretKeyRef:|name:\"my-secrets\"|key:\"KEK\"" && [ "$(grep -c "name: STUDIO_ENCRYPTION_KEY" <<<"$out")" -eq 1 ]'

[ "$failures" -eq 0 ] || { echo "$failures check(s) failed"; exit 1; }
