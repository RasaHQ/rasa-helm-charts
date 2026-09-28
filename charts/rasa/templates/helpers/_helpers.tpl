{{/*
Expand the name of the chart.
*/}}
{{- define "rasa.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rasa.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rasa.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rasa.labels" -}}
helm.sh/chart: {{ include "rasa.chart" . }}
{{ include "rasa.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- with .Values.global.extraDeploymentLabels }}
{{ toYaml . -}}
{{- end }}
{{- end }}

{{/*
Selector labels for Rasa OSS/Plus
*/}}
{{- define "rasa.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rasa.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Render topologySpreadConstraints, defaulting each entry's labelSelector to the
component's own selector labels. A constraint with no labelSelector matches no
pods, so the skew is always zero and the constraint would never bind.
Usage: include "rasa.topologySpreadConstraints" (dict "constraints" <list> "selectorLabels" (include "rasa.<component>.selectorLabels" $))
*/}}
{{- define "rasa.topologySpreadConstraints" -}}
{{- $selector := dict "matchLabels" (fromYaml .selectorLabels) -}}
{{- $out := list -}}
{{- range .constraints -}}
{{- $constraint := deepCopy . -}}
{{- if not (hasKey $constraint "labelSelector") -}}
{{- $_ := set $constraint "labelSelector" $selector -}}
{{- end -}}
{{- $out = append $out $constraint -}}
{{- end -}}
{{- toYaml $out -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rasa.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rasa.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return DNS policy depends on host network configuration
*/}}
{{- define "rasa.dnsPolicy" -}}
{{- if and .Values.hostNetwork (empty .Values.dnsPolicy) }}
{{- print "ClusterFirstWithHostNet" }}
{{- else if and (not .Values.hostNetwork) (empty .Values.dnsPolicy) }}
{{- print "ClusterFirst" }}
{{- else if .Values.dnsPolicy }}
{{- .Values.dnsPolicy }}
{{- end }}
{{- end }}

{{/*
Determine rasa server to run with arguments
*/}}
{{- define "rasa.defaultArgs" -}}
- run
{{- if .Values.rasa.enableApi }}
- --enable-api
{{- end }}
- --port
- "{{ .Values.rasa.port }}"
{{- if .Values.rasa.cors }}
- --cors
- {{ .Values.rasa.cors | quote }}
{{- end }}
{{- if .Values.rasa.debugMode }}
- --debug
{{- end }}
{{- end -}}

{{/*
Report whether the chart itself starts the Rasa HTTP API.

enableApi alone does not answer this: --enable-api is only rendered when the
chart builds the arguments, which it skips when rasa.args is set. rasa.command
is deliberately not part of this — command and args render independently, so
overriding the entrypoint leaves --enable-api in place. Arguments you supply
yourself are opaque, so an --enable-api inside rasa.args or extraArgs is
invisible here.
*/}}
{{- define "rasa.apiServed" -}}
{{- if and .Values.rasa.enableApi (kindIs "invalid" .Values.args) -}}
true
{{- end -}}
{{- end -}}

{{/*
Report whether an API credential reaches the container.

rasa.overrideEnv replaces the generated environment block, so it decides which
list to scan: a token in extraEnv is discarded as soon as overrideEnv is
non-empty, and an authToken or jwtSecret with it. Both this and deployment.yaml
test truthiness, so an empty overrideEnv keeps the generated block in both.
envFrom is opaque at render time and counts as authenticated rather than
blocking a legitimate install.
*/}}
{{- define "rasa.apiAuthenticated" -}}
{{- $named := false -}}
{{- $env := .Values.overrideEnv | default (.Values.extraEnv | default list) -}}
{{- range $env -}}
{{-   if or (eq .name "AUTH_TOKEN") (eq .name "JWT_SECRET") -}}
{{-     $named = true -}}
{{-   end -}}
{{- end -}}
{{- if or $named .Values.envFrom (and (or .Values.rasa.authToken .Values.rasa.jwtSecret) (not .Values.overrideEnv)) -}}
true
{{- end -}}
{{- end -}}

{{/*
Report whether an enabled Rasa HTTP API authenticates nobody.

This alone only warrants a warning, not a refusal. enableApi has to default to
true because rasa run exits when it has neither a model nor the API to load one
through, so failing on this predicate would make a no-values install
unrenderable. allowUnauthenticatedApi silences both tiers for anyone who has
already decided an open API is acceptable.
*/}}
{{- define "rasa.apiUnauthenticated" -}}
{{- if and (include "rasa.apiServed" .) (not (include "rasa.apiAuthenticated" .)) (not .Values.rasa.allowUnauthenticatedApi) -}}
true
{{- end -}}
{{- end -}}

{{/*
Report whether this chart itself puts the Service on the network.

A ClusterIP Service is not a security boundary and a route to it can be added
without touching this chart, which is why the warning above is unconditional.
This predicate is narrower on purpose: it is what the chart can actually prove
it is doing, so it is what the chart is willing to refuse over. service.type is
defaulted rather than read directly, so `service: {}` does not read as routed.
*/}}
{{- define "rasa.apiRouted" -}}
{{- if or .Values.ingress.enabled (ne (.Values.service.type | default "ClusterIP") "ClusterIP") .Values.hostNetwork -}}
true
{{- end -}}
{{- end -}}

{{/*
Refuse to render an unauthenticated API that this chart routes traffic to.

Composed from the two predicates above rather than repeating their conditions,
so the NOTES warning and this refusal cannot drift apart: anything that fails
here also warns, and the warning is strictly the wider set.
*/}}
{{- define "rasa.validateApiExposure" -}}
{{- if and (include "rasa.apiUnauthenticated" .) (include "rasa.apiRouted" .) -}}
{{- fail "rasa.enableApi is true, no API credential reaches the container, and this release routes traffic to it - rasa.ingress.enabled is true, rasa.service.type is not ClusterIP, or hostNetwork is true. That would put an unauthenticated Rasa HTTP API, including its model-management endpoints, on the network. Supply a credential with rasa.authToken or rasa.jwtSecret (note that rasa.overrideEnv discards those, since it replaces the generated environment), or as an AUTH_TOKEN / JWT_SECRET entry in rasa.overrideEnv or rasa.extraEnv, or through rasa.envFrom. Alternatively set rasa.enableApi=false, stop routing to it, or acknowledge the risk with rasa.allowUnauthenticatedApi=true when something in front of the chart already authenticates callers." -}}
{{- end -}}
{{- end -}}

{{/*
Merge a structured map with its raw-YAML counterpart, or return nothing when
both are empty.

configmap.yaml and both volume defines share this so they cannot disagree about
whether there is configuration to ship — they once did, and endpointsRaw
produced a ConfigMap that nothing mounted. fromYaml reports a parse failure as a
map holding only an Error key, hence the length check.

Usage: include "rasa.mergedConfig" (dict "structured" ... "raw" ... "field" "endpointsRaw")
*/}}
{{- define "rasa.mergedConfig" -}}
{{- $merged := dict -}}
{{- if .raw -}}
{{-   $trimmed := .raw | toString | trim -}}
{{-   if $trimmed -}}
{{-     $parsed := fromYaml $trimmed -}}
{{-     if and (hasKey $parsed "Error") (eq (len $parsed) 1) -}}
{{-       fail (printf "rasa.%s is not valid YAML (reported while rendering the ConfigMap, which the Deployment checksums, so Helm may name deployment.yaml as the location): %s" .field (index $parsed "Error")) -}}
{{-     end -}}
{{-     $merged = $parsed -}}
{{-   end -}}
{{- end -}}
{{- if .structured -}}
{{-   $merged = merge (deepCopy .structured) $merged -}}
{{- end -}}
{{- if $merged -}}
{{- toYaml $merged -}}
{{- end -}}
{{- end -}}

{{/*
Report whether the chart has any endpoints configuration to mount.
*/}}
{{- define "rasa.hasEndpoints" -}}
{{- include "rasa.mergedConfig" (dict "structured" .Values.rasa.endpoints "raw" .Values.rasa.endpointsRaw "field" "endpointsRaw") -}}
{{- end -}}

{{/*
Report whether the chart has any integrations configuration to mount.
*/}}
{{- define "rasa.hasIntegrations" -}}
{{- include "rasa.mergedConfig" (dict "structured" .Values.rasa.integrations "raw" .Values.rasa.integrationsRaw "field" "integrationsRaw") -}}
{{- end -}}

{{/*
Refuse to render when a values block the chart dereferences has been nulled.

Helm treats `foo: null` as "delete this key", so the block does not fall back
to the chart default - it disappears, and every .Values.foo.bar below it fails
with "nil pointer evaluating interface {}.bar", which names the template
rather than the mistake. hasKey is the reliable signal because a nulled key is
absent after coalescing.
*/}}
{{- define "rasa.validateNoNulledKeys" -}}
{{- $required := list "rasa" "image" "serviceAccount" "podSecurityContext" "containerSecurityContext" "service" "livenessProbe" "readinessProbe" "ingress" "autoscaling" "persistence" "networkPolicy" "global" -}}
{{- $missing := list -}}
{{- range $k := $required -}}
{{- if not (hasKey $.Values $k) -}}{{- $missing = append $missing $k -}}{{- end -}}
{{- end -}}
{{- range $k := (list "license" "telemetry" "logging") -}}
{{- if not (hasKey (index $.Values "rasa" | default dict) $k) -}}{{- $missing = append $missing (printf "rasa.%s" $k) -}}{{- end -}}
{{- end -}}
{{- if $missing -}}
{{- fail (printf "these values keys were set to null, which deletes them rather than restoring the chart default: %s. Remove the key entirely to use the default, or give it a value. To switch a component off use its own flag (for example persistence.create=false or ingress.enabled=false)." (join ", " $missing)) -}}
{{- end -}}
{{- end -}}
