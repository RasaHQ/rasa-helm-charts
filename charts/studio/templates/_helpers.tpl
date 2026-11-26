{{/*
Expand the name of the chart.
*/}}
{{- define "studio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "studio.fullname" -}}
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
{{- define "studio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "studio.labels" -}}
helm.sh/chart: {{ include "studio.chart" . }}
{{ include "studio.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ if .Values.global.extraDeploymentLabels -}}
{{- $.Values.global.extraDeploymentLabels | toYaml -}}
{{- end }}
{{- end }}

{{/*
Selector labels for Studio
*/}}
{{- define "studio.selectorLabels" -}}
app.kubernetes.io/name: {{ include "studio.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the app service account to use for Studio App
*/}}
{{- define "studio.app.serviceAccountName" -}}
{{- if .Values.app.serviceAccount.create }}
{{- default (printf "%s-app" (include "studio.fullname" .)) .Values.app.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.app.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the eventIngestion service account to use for Event Ingestion
*/}}
{{- define "studio.eventIngestion.serviceAccountName" -}}
{{- if .Values.eventIngestion.serviceAccount.create }}
{{- default (printf "%s-app-ingestion" (include "studio.fullname" .)) .Values.eventIngestion.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.eventIngestion.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the app migration service account to use for Database Migration Job
*/}}
{{- define "studio.app.migration.serviceAccountName" -}}
{{- if .Values.app.migration.serviceAccount.create }}
{{- default (printf "%s-app-migration" (include "studio.fullname" .)) .Values.app.migration.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.app.migration.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Return DNS policy depends on host network configuration
*/}}
{{- define "studio.dnsPolicy" -}}
{{- if and .Values.hostNetwork (empty .Values.dnsPolicy) }}
{{- print "ClusterFirstWithHostNet" }}
{{- else if and (not .Values.hostNetwork) (empty .Values.dnsPolicy) }}
{{- print "ClusterFirst" }}
{{- else if .Values.dnsPolicy }}
{{- .Values.dnsPolicy }}
{{- end }}
{{- end }}

{{/*
Return annotations for deployment, combining global and per-deployment annotations for Studio App
*/}}
{{- define "app.deployment.annotations" -}}
{{- $global := .Values.deploymentAnnotations | default dict | deepCopy }}
{{- $additional := .Values.app.annotations | default dict | deepCopy }}
{{- $annotations := mergeOverwrite $additional $global -}}
{{- if $annotations -}}
annotations:
  {{- toYaml $annotations | nindent 2 }}
{{- end -}}
{{- end }}

{{/*
Return annotations for deployment, combining global and per-deployment annotations for Event Ingestion
*/}}
{{- define "eventingestion.deployment.annotations" -}}
{{- $global := .Values.deploymentAnnotations | default dict | deepCopy }}
{{- $additional := .Values.eventIngestion.annotations | default dict }}
{{- $annotations := merge $global $additional -}}
{{- if $annotations -}}
annotations:
  {{- toYaml $annotations | nindent 2 }}
{{- end -}}
{{- end }}


{{/*
Return annotations for ingress, combining global and per-service annotations for Studio App
*/}}
{{- define "app.ingress.annotations" -}}
{{- $global := dig "ingressAnnotations" (dict) (.Values.global | default dict) | default dict | deepCopy }}
{{- $additional := .Values.app.ingress.extraAnnotations | default dict | deepCopy }}
{{- /* Component wins on key conflicts: global.ingressAnnotations is a baseline
       applied to every ingress, per-ingress annotations are local exceptions.
       Mirrors the rasa subchart ingress, which does merge (component) (global). */ -}}
{{- $annotations := merge $additional $global -}}
{{- if $annotations -}}
annotations:
  {{- toYaml $annotations | nindent 2 }}
{{- end -}}
{{- end }}


{{/*
Return image repository with tag and image name for Studio App
*/}}
{{- define "studio.app.image" -}}
{{- if hasSuffix "/" .Values.repository -}}
"{{ .Values.repository }}{{ .Values.app.image.name }}:{{ .Values.tag | default .Chart.AppVersion }}"
{{- else -}}
"{{ .Values.repository }}/{{ .Values.app.image.name }}:{{ .Values.tag | default .Chart.AppVersion }}"
{{- end -}}
{{- end -}}

{{/*
Return image repository with tag and image name for Studio App migration
*/}}
{{- define "studio.migration.image" -}}
{{- if hasSuffix "/" .Values.repository -}}
"{{ .Values.repository }}{{ .Values.app.migration.image.name }}:{{ .Values.tag | default .Chart.AppVersion }}"
{{- else -}}
"{{ .Values.repository }}/{{ .Values.app.migration.image.name }}:{{ .Values.tag | default .Chart.AppVersion }}"
{{- end -}}
{{- end -}}

{{/*
Return image repository with tag and image name for Event Ingestion
*/}}
{{- define "studio.eventIngestion.image" -}}
{{- if hasSuffix "/" .Values.repository -}}
"{{ .Values.repository }}{{ .Values.eventIngestion.image.name }}:{{ .Values.tag | default .Chart.AppVersion }}"
{{- else -}}
"{{ .Values.repository }}/{{ .Values.eventIngestion.image.name }}:{{ .Values.tag | default .Chart.AppVersion }}"
{{- end -}}
{{- end -}}


{{/*
Studio App pod scheduling configuration
*/}}
{{- define "studio.app.scheduling" -}}
{{- if .Values.config.nodeSelector }}
nodeSelector:
  {{- .Values.config.nodeSelector | toYaml | nindent 2 }}
{{- else if .Values.app.nodeSelector }}
nodeSelector:
  {{- .Values.app.nodeSelector | toYaml | nindent 2 }}
{{- end }}
{{- if .Values.config.affinity }}
affinity:
  {{- .Values.config.affinity | toYaml | nindent 2 }}
{{- else if .Values.app.affinity }}
affinity:
  {{- .Values.app.affinity | toYaml | nindent 2 }}
{{- end }}
{{- if .Values.config.tolerations }}
tolerations:
  {{- .Values.config.tolerations | toYaml | nindent 2 }}
{{- else if .Values.app.tolerations }}
tolerations:
  {{- .Values.app.tolerations | toYaml | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Event Ingestion pod scheduling configuration
*/}}
{{- define "studio.eventIngestion.scheduling" -}}
{{- if .Values.config.nodeSelector }}
nodeSelector:
  {{- .Values.config.nodeSelector | toYaml | nindent 2 }}
{{- else if .Values.eventIngestion.nodeSelector }}
nodeSelector:
  {{- .Values.eventIngestion.nodeSelector | toYaml | nindent 2 }}
{{- end }}
{{- if .Values.config.affinity }}
affinity:
  {{- .Values.config.affinity | toYaml | nindent 2 }}
{{- else if .Values.eventIngestion.affinity }}
affinity:
  {{- .Values.eventIngestion.affinity | toYaml | nindent 2 }}
{{- end }}
{{- if .Values.config.tolerations }}
tolerations:
  {{- .Values.config.tolerations | toYaml | nindent 2 }}
{{- else if .Values.eventIngestion.tolerations }}
tolerations:
  {{- .Values.eventIngestion.tolerations | toYaml | nindent 2 }}
{{- end }}
{{- end }}


{{/*
Studio App migration pod scheduling configuration
*/}}
{{- define "studio.app.migration.scheduling" -}}
{{- if .Values.config.nodeSelector }}
nodeSelector:
  {{- .Values.config.nodeSelector | toYaml | nindent 2 }}
{{- else if .Values.app.migration.nodeSelector }}
nodeSelector:
  {{- .Values.app.migration.nodeSelector | toYaml | nindent 2 }}
{{- end }}
{{- if .Values.config.affinity }}
affinity:
  {{- .Values.config.affinity | toYaml | nindent 2 }}
{{- else if .Values.app.migration.affinity }}
affinity:
  {{- .Values.app.migration.affinity | toYaml | nindent 2 }}
{{- end }}
{{- if .Values.config.tolerations }}
tolerations:
  {{- .Values.config.tolerations | toYaml | nindent 2 }}
{{- else if .Values.app.migration.tolerations }}
tolerations:
  {{- .Values.app.migration.tolerations | toYaml | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Resolve the model service ingress host
*/}}
{{- define "studio.modelServiceHost" -}}
{{- $ingress := dig "ingress" (dict) (.Values.rasa | default dict) -}}
{{- $firstHost := dig "host" "" (($ingress.hosts | default list | first) | default dict) -}}
{{- $globalHost := dig "ingressHost" "" (.Values.global | default dict) -}}
{{- if $globalHost -}}
{{- /* Precedence mirrors the rasa subchart ingress exactly
       (global.ingressHost | default hosts[*].host), so the derived URL
       always matches the host actually served. */ -}}
{{- $globalHost -}}
{{- else if $firstHost -}}
{{- $firstHost -}}
{{- end -}}
{{- end -}}

{{/*
Model service ingress path prefix
*/}}
{{- define "studio.modelServiceIngressPath" -}}
{{- $ingress := dig "ingress" (dict) (.Values.rasa | default dict) -}}
{{- $firstHost := ($ingress.hosts | default list | first) | default dict -}}
{{- $firstPath := dig "path" "" (($firstHost.paths | default list | first) | default dict) -}}
{{- if $firstPath -}}
{{- $firstPath -}}
{{- else -}}
/modelservice
{{- end -}}
{{- end -}}

{{/*
Model service URL for RASA_MODEL_SERVER_BASE_URL (scheme + host + ingress path)
*/}}
{{- define "studio.modelServiceUrl" -}}
{{- printf "%s://%s%s" .Values.config.connectionType (include "studio.modelServiceHost" .) (include "studio.modelServiceIngressPath" .) -}}
{{- end -}}

{{/*
Guard against `rasa: null`. Nulling the key deletes it, which breaks the
subchart condition (rasa.enabled) and silently re-enables the Rasa Pro
subchart with its default values. After coalescing, .Values.rasa is
re-populated from the subchart's own defaults, which never define `enabled`
— so a missing `enabled` key is the reliable signal of a nulled block.
*/}}
{{- define "studio.rasa.validate" -}}
{{- if not (hasKey (.Values.rasa | default dict) "enabled") -}}
{{- fail "rasa.enabled is not set — was `rasa: null` used? Nulling the key deletes it and re-enables the Rasa Pro subchart with default values. Disable it with `rasa.enabled: false` instead" -}}
{{- end -}}
{{- end -}}

{{/*
Validate values the chart cannot install without.

Only covers what is visible at render time. Secret *contents* are not — a short
AUTH_SECRET or an expired licence cannot be seen here, and a missing Secret key
already blocks container start. What is checked is config that can produce a
fully successful install with a broken release.
*/}}
{{- define "studio.requiredValues.validate" -}}
{{- $db := .Values.config.database -}}
{{- if and (ne ($db.useAwsIamAuth | toString) "true") (not $db.password) -}}
{{- fail "config.database.password is required unless config.database.useAwsIamAuth is \"true\" — set config.database.password.secretName and .secretKey, or enable IAM auth" -}}
{{- end -}}
{{- if hasKey (.Values.app.webClient.config | default dict) "MS_API_URL" -}}
{{- fail "app.webClient.config.MS_API_URL was removed: the browser reaches the model service through Studio at /api/rasa/model-service/. For an external Rasa Pro (rasa.enabled: false), set MS_API_URL in app.env to its base URL, without /modelservice" -}}
{{- end -}}
{{- if .Values.rasa.enabled -}}
{{- $declared := list -}}
{{- range (.Values.rasa.overrideEnv | default list) -}}
{{- $declared = append $declared .name -}}
{{- end -}}
{{- /* Each entry is a list of names that satisfy the requirement. The licence
       has two: RASA_LICENSE is canonical, RASA_PRO_LICENSE is the legacy name
       rasa still reads, and real consumers use it. */ -}}
{{- range $accepted := list (list "RASA_LICENSE" "RASA_PRO_LICENSE") (list "OPENAI_API_KEY") -}}
{{- $found := false -}}
{{- range $name := $accepted -}}
{{- if has $name $declared -}}
{{- $found = true -}}
{{- end -}}
{{- end -}}
{{- if not $found -}}
{{- fail (printf "rasa.enabled is true but rasa.overrideEnv declares no %s entry. rasa.overrideEnv replaces the chart default list wholesale, which drops the model service credentials — re-declare the defaults from values.yaml, or set rasa.enabled: false" (join " or " $accepted)) -}}
{{- end -}}
{{- end -}}
{{- $ref := include "studio.previewEvents.secretRef" . | fromJson -}}
{{- $clientId := "" -}}
{{- $secretKeyRef := dict -}}
{{- range (.Values.rasa.overrideEnv | default list) -}}
{{- if eq .name "STUDIO_EVENTS_CLIENT_ID" -}}
{{- $clientId = .value | default "" | toString -}}
{{- else if eq .name "STUDIO_EVENTS_CLIENT_SECRET" -}}
{{- $secretKeyRef = dig "valueFrom" "secretKeyRef" (dict) . -}}
{{- end -}}
{{- end -}}
{{- if ne $clientId "studio-preview" -}}
{{- fail "rasa.overrideEnv needs STUDIO_EVENTS_CLIENT_ID with the value studio-preview, or preview bots cannot send events to Studio — re-declare the default entry from values.yaml" -}}
{{- end -}}
{{- if or (ne (get $secretKeyRef "name" | default "") $ref.secretName) (ne (get $secretKeyRef "key" | default "") $ref.secretKey) -}}
{{- fail (printf "rasa.overrideEnv needs STUDIO_EVENTS_CLIENT_SECRET from secretKeyRef name %q, key %q, the secret that app.previewEventsSecret selects, or Studio refuses the events of preview bots" $ref.secretName $ref.secretKey) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate event-ingestion topology configuration.
*/}}
{{- define "studio.eventIngestion.validate" -}}
{{- if hasKey .Values.eventIngestion "enabled" -}}
{{- fail "eventIngestion.enabled was removed; use eventIngestion.mode: colocated|separate|disabled" -}}
{{- end -}}
{{- $mode := .Values.eventIngestion.mode | default "disabled" -}}
{{- if not (has $mode (list "colocated" "separate" "disabled")) -}}
{{- fail (printf "eventIngestion.mode must be one of colocated|separate|disabled, got %q" $mode) -}}
{{- end -}}
{{- $colocated := eq $mode "colocated" -}}
{{- $separate := eq $mode "separate" -}}
{{- if and $colocated $separate -}}
{{- fail "invalid eventIngestion.mode: colocated and separate cannot both be active" -}}
{{- end -}}
{{- end -}}

{{/*
Return the event-ingestion mode.
*/}}
{{- define "studio.eventIngestion.mode" -}}
{{- .Values.eventIngestion.mode | default "disabled" -}}
{{- end -}}

{{/*
Report whether event ingestion is co-located with the Studio App.

Each emits "true" or nothing, never the string "false". include returns a
string and Go templates treat any non-empty string as true, so a helper
returning "false" would make `{{ if include ... }}` fire in every mode. This
shape matches the rest of both charts and lets the guard be written plainly.

The chart's own event-ingestion templates inline
`eq (include "studio.eventIngestion.mode" .) "separate"`, so these three are
intentionally unreferenced here -- they exist so anyone extending the chart
can branch on the mode without repeating the comparison.
*/}}
{{- define "studio.eventIngestion.isColocated" -}}
{{- if eq (include "studio.eventIngestion.mode" .) "colocated" -}}
true
{{- end -}}
{{- end -}}

{{/*
Report whether event ingestion runs in a separate deployment.
*/}}
{{- define "studio.eventIngestion.isSeparate" -}}
{{- if eq (include "studio.eventIngestion.mode" .) "separate" -}}
true
{{- end -}}
{{- end -}}

{{/*
Report whether event ingestion is disabled.
*/}}
{{- define "studio.eventIngestion.isDisabled" -}}
{{- if eq (include "studio.eventIngestion.mode" .) "disabled" -}}
true
{{- end -}}
{{- end -}}

{{/*
Resolve the Studio App ingress host.
*/}}
{{- define "studio.appHost" -}}
{{- $globalHost := dig "ingressHost" "" (.Values.global | default dict) -}}
{{- if $globalHost -}}
{{- /* global.ingressHost means "one host for everything" — it wins for the
       same reason it wins in the rasa subchart ingress (global | default
       .host): the URL must match the host actually served. */ -}}
{{- $globalHost -}}
{{- else if .Values.app.ingress.hostName -}}
{{- .Values.app.ingress.hostName -}}
{{- end -}}
{{- end -}}

{{/*
Studio's public origin, BETTER_AUTH_BASE_URL. The token issuer derives from it.
*/}}
{{- define "studio.authBaseUrl" -}}
{{- $host := include "studio.appHost" . | required "global.ingressHost or app.ingress.hostName is required: BETTER_AUTH_BASE_URL, WEB_CLIENT_URL, API_ENDPOINT and STUDIO_TOKEN_ISSUER derive from it" -}}
{{- printf "%s://%s" .Values.config.connectionType $host -}}
{{- end -}}


{{/*
Studio App external URL for CORS_ORIGINS.
*/}}
{{- define "studio.webClientUrl" -}}
{{- printf "%s://%s" .Values.config.connectionType (include "studio.appHost" .) -}}
{{- end -}}

{{/*
The Secret that holds the preview event client secret, as JSON: either
app.previewEventsSecret.existingSecret or the Secret the chart generates. The
rasa subchart reads its env as static values, so the generated Secret has a
fixed name that the default rasa.overrideEnv can refer to.
*/}}
{{- define "studio.previewEvents.secretRef" -}}
{{- with .Values.app.previewEventsSecret.existingSecret -}}
{{- dict "secretName" .secretName "secretKey" .secretKey | toJson -}}
{{- else -}}
{{- dict "secretName" "studio-preview-events" "secretKey" "STUDIO_EVENTS_CLIENT_SECRET" | toJson -}}
{{- end -}}
{{- end -}}
