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
app.kubernetes.io/app: {{ .Chart.Name }}
{{ if .Values.global.additionalDeploymentLabels -}}
{{- $.Values.global.additionalDeploymentLabels | toYaml -}}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "studio.selectorLabels" -}}
app.kubernetes.io/name: {{ include "studio.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the backend service account to use for Backend
*/}}
{{- define "studio.backend.serviceAccountName" -}}
{{- if .Values.backend.serviceAccount.create }}
{{- default (include "studio.fullname" .) .Values.backend.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.backend.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the eventIngestion service account to use for Event Ingestion
*/}}
{{- define "studio.eventIngestion.serviceAccountName" -}}
{{- if .Values.eventIngestion.serviceAccount.create }}
{{- default (include "studio.fullname" .) .Values.eventIngestion.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.eventIngestion.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the keycloak service account to use for Keycloak
*/}}
{{- define "studio.keycloak.serviceAccountName" -}}
{{- if .Values.keycloak.serviceAccount.create }}
{{- default (include "studio.fullname" .) .Values.keycloak.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.keycloak.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the frontend service account to use for Web Client
*/}}
{{- define "studio.webClient.serviceAccountName" -}}
{{- if .Values.webClient.serviceAccount.create }}
{{- default (include "studio.fullname" .) .Values.webClient.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.webClient.serviceAccount.name }}
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
Return image repository with tag and image name for Backend
*/}}
{{- define "studio.backend.image" -}}
{{- if hasSuffix "/" .Values.repository -}}
"{{ .Values.repository }}{{ .Values.backend.image.name }}:{{ .Values.tag }}"
{{- else -}}
"{{ .Values.repository }}/{{ .Values.backend.image.name }}:{{ .Values.tag }}"
{{- end -}}
{{- end -}}

{{/*
Return image repository with tag and image name for Backend migration
*/}}
{{- define "studio.migration.image" -}}
{{- if hasSuffix "/" .Values.repository -}}
"{{ .Values.repository }}{{ .Values.backend.migration.image.name }}:{{ .Values.tag }}"
{{- else -}}
"{{ .Values.repository }}/{{ .Values.backend.migration.image.name }}:{{ .Values.tag }}"
{{- end -}}
{{- end -}}

{{/*
Return image repository with tag and image name for Web Client
*/}}
{{- define "studio.webClient.image" -}}
{{- if hasSuffix "/" .Values.repository -}}
"{{ .Values.repository }}{{ .Values.webClient.image.name }}:{{ .Values.tag }}"
{{- else -}}
"{{ .Values.repository }}/{{ .Values.webClient.image.name }}:{{ .Values.tag }}"
{{- end -}}
{{- end -}}

{{/*
Return image repository with tag and image name for Event Ingestion
*/}}
{{- define "studio.eventIngestion.image" -}}
{{- if hasSuffix "/" .Values.repository -}}
"{{ .Values.repository }}{{ .Values.eventIngestion.image.name }}:{{ .Values.tag }}"
{{- else -}}
"{{ .Values.repository }}/{{ .Values.eventIngestion.image.name }}:{{ .Values.tag }}"
{{- end -}}
{{- end -}}

{{/*
Return image repository with tag and image name for Keycloak
*/}}
{{- define "studio.keycloak.image" -}}
{{- if hasSuffix "/" .Values.repository -}}
"{{ .Values.repository }}{{ .Values.keycloak.image.name }}:{{ .Values.tag }}"
{{- else -}}
"{{ .Values.repository }}/{{ .Values.keycloak.image.name }}:{{ .Values.tag }}"
{{- end -}}
{{- end -}}
