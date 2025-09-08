{{/*
Expand the name of the chart.
*/}}
{{- define "op-kits.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "op-kits.fullname" -}}
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
{{- define "op-kits.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "op-kits.labels" -}}
helm.sh/chart: {{ include "op-kits.chart" . }}
{{ include "op-kits.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "op-kits.selectorLabels" -}}
app.kubernetes.io/name: {{ include "op-kits.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
CloudNativePG Cluster name
*/}}
{{- define "op-kits.cloudnativepg.clusterName" -}}
{{- if .Values.cloudnativepg.cluster.nameOverride }}
{{- .Values.cloudnativepg.cluster.nameOverride }}
{{- else }}
{{- printf "%s-pg" (include "op-kits.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Strimzi Kafka cluster name
*/}}
{{- define "op-kits.strimzi.kafkaName" -}}
{{- if .Values.strimzi.kafka.nameOverride }}
{{- .Values.strimzi.kafka.nameOverride }}
{{- else }}
{{- printf "%s-kafka" (include "op-kits.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Common labels for CloudNativePG resources
*/}}
{{- define "op-kits.cloudnativepg.labels" -}}
{{ include "op-kits.labels" . }}
app.kubernetes.io/component: database
{{- end }}

{{/*
Common labels for Strimzi resources
*/}}
{{- define "op-kits.strimzi.labels" -}}
{{ include "op-kits.labels" . }}
app.kubernetes.io/component: messaging
{{- end }}

{{/*
Namespace helper - use release namespace or specified namespace
*/}}
{{- define "op-kits.namespace" -}}
{{- default "default" .Release.Namespace }}
{{- end }}
