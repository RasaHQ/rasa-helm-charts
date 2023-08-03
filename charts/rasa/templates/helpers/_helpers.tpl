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
{{ if .Values.global.additionalDeploymentLabels -}}
{{- $.Values.global.additionalDeploymentLabels | toYaml -}}
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
Selector labels for Rasa Pro Services
*/}}
{{- define "rasa.rasaProServices.selectorLabels" -}}
app.kubernetes.io/name: rasa-pro-services
app.kubernetes.io/instance: {{ .Release.Name }}
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
Create the name of the service account to use
*/}}
{{- define "rasa.rasaProServices.serviceAccountName" -}}
{{- if .Values.rasaProServices.serviceAccount.create }}
{{- default "rasa-pro-services" .Values.rasaProServices.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.rasaProServices.serviceAccount.name }}
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
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "networkPolicy.apiVersion" -}}
{{- if semverCompare ">=1.4-0, <1.7-0" .Capabilities.KubeVersion.GitVersion }}
{{- print "extensions/v1beta1" }}
{{- else }}
{{- print "networking.k8s.io/v1" }}
{{- end }}
{{- end }}

{{/*
Determine rasa server to run with arguments
*/}}
{{- define "rasa.serverType" -}}
- run
{{- if .Values.rasa.settings.enableApi }}
- --enable-api
- --jwt-method
- {{ .Values.rasa.settings.jwtMethod }}
{{- if and .Values.rasa.settings.jwtSecret.secretName .Values.rasa.settings.jwtSecret.secretKey }}
- --jwt-secret
- "$(cat /app/secrets/{{ .Values.rasa.settings.jwtSecret.secretKey }})"
{{- end }}
{{- if and .Values.rasa.settings.authToken.secretName .Values.rasa.settings.authToken.secretKey }}
- --auth-token
- "$(cat /app/secrets/{{ .Values.rasa.settings.authToken.secretKey }})"
{{- end }}
{{- end -}}
{{- end -}}
