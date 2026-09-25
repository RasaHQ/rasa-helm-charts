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
{{- with .Values.global.additionalDeploymentLabels }}
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
{{- if .Values.rasa.serviceAccount.create }}
{{- default (include "rasa.fullname" .) .Values.rasa.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.rasa.serviceAccount.name }}
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
Report whether this release actually serves the Rasa HTTP API.

settings.enableApi alone does not answer this. The chart only renders
`--enable-api` when it builds the arguments itself (defaultArgs), so setting
rasa.args, disabling settings.useDefaultArgs, or replacing the process with
rasa.command all leave enableApi describing nothing. Rasa Studio consumes this
chart exactly that way.

This mirrors the condition deployment.yaml uses to emit the default arguments.
Note that rasa.command does NOT belong here: command and args render
independently, so overriding the entrypoint still leaves --enable-api in args.

Caveat: arguments you supply yourself are opaque to the chart. If your own
rasa.args or rasa.additionalArgs contain --enable-api, this reports nothing
and the exposure checks below do not fire.
*/}}
{{- define "rasa.apiServed" -}}
{{- if and .Values.rasa.enableApi .Values.rasa.useDefaultArgs (not .Values.rasa.args) -}}
true
{{- end -}}
{{- end -}}

{{/*
Report whether an API credential actually reaches the container.

Configuring settings.authToken is not sufficient: rasa.overrideEnv replaces the
generated environment block wholesale, so AUTH_TOKEN and JWT_SECRET never
render. A token that does not reach the pod is not authentication.

The converse also holds, so this counts every route that delivers one. Which
route applies depends on overrideEnv: deployment.yaml emits overrideEnv INSTEAD
of the generated block, and additionalEnv lives inside that generated block, so
a token in additionalEnv is discarded the moment overrideEnv is set. This
mirrors that branch rather than scanning both lists. envFrom contents are
opaque at render time, so its presence counts as authentication rather than
blocking a legitimate install.
*/}}
{{- define "rasa.apiAuthenticated" -}}
{{- $named := false -}}
{{- $env := .Values.rasa.overrideEnv | default (.Values.rasa.additionalEnv | default list) -}}
{{- range $env -}}
{{-   if or (eq .name "AUTH_TOKEN") (eq .name "JWT_SECRET") -}}
{{-     $named = true -}}
{{-   end -}}
{{- end -}}
{{- if or $named .Values.rasa.envFrom (and (or .Values.rasa.authToken .Values.rasa.jwtSecret) (not .Values.rasa.overrideEnv)) -}}
true
{{- end -}}
{{- end -}}

{{/*
Report whether the Service is reachable from outside the cluster. An ingress or
any Service type other than ClusterIP puts the API in front of traffic the
cluster does not mediate.
*/}}
{{- define "rasa.apiExposed" -}}
{{- if or .Values.rasa.ingress.enabled .Values.hostNetwork (ne (.Values.rasa.service.type | default "ClusterIP") "ClusterIP") -}}
true
{{- end -}}
{{- end -}}

{{/*
Refuse to render an externally reachable Rasa HTTP API that authenticates
nobody. Included from deployment.yaml so it is evaluated for every exposure
route, not only when an ingress happens to render.
*/}}
{{- define "rasa.validateApiExposure" -}}
{{- if and (include "rasa.apiServed" .) (include "rasa.apiExposed" .) (not (include "rasa.apiAuthenticated" .)) (not .Values.rasa.allowUnauthenticatedApi) -}}
{{- fail "This release exposes the Rasa HTTP API outside the cluster (rasa.ingress.enabled, or rasa.service.type is not ClusterIP) but no API credential reaches the container, so the API would accept unauthenticated requests. Supply a credential with rasa.authToken or rasa.jwtSecret (note that rasa.overrideEnv discards those), or as an AUTH_TOKEN / JWT_SECRET entry in rasa.additionalEnv or rasa.overrideEnv, or through rasa.envFrom. Alternatively set rasa.enableApi=false, or acknowledge the risk with rasa.allowUnauthenticatedApi=true when your ingress or service mesh already authenticates callers." -}}
{{- end -}}
{{- end -}}

{{/*
Merge a structured settings map with its raw-YAML counterpart and return the
result, or nothing when both are empty.

configmap.yaml, rasa.containers.volumes and rasa.containers.volumeMounts must
all agree on whether there is configuration to ship. They used to disagree:
the ConfigMap counted the *Raw variants while the volumes did not, so
endpointsRaw alone produced a ConfigMap that was never mounted and the
configuration was silently dropped.

fromYaml reports a parse failure as a map holding exactly one key, Error, so the
length is checked too: raw YAML whose own top-level key happens to be "Error"
must not be misreported as malformed.

Usage: include "rasa.mergedConfig" (dict "structured" .Values... "raw" .Values... "field" "endpointsRaw")
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
Report whether the chart has any credentials configuration to mount.
*/}}
{{- define "rasa.hasCredentials" -}}
{{- include "rasa.mergedConfig" (dict "structured" .Values.rasa.credentials "raw" .Values.rasa.credentialsRaw "field" "credentialsRaw") -}}
{{- end -}}
