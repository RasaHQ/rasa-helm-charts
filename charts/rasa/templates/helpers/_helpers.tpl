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
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rasa.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rasa.name" . }}
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
{{- default (include "rasa.fullname" .) .Values.rasaProServices.serviceAccount.name }}
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
Determine rasa server to run with arguments
*/}}
{{- define "rasa.serverType" -}}
- run
{{- if .Values.rasa.settings.enableAPI }}
- --enable-api
{{- end -}}
{{- end -}}

{{/*
Determine if a model server endpoint is used
*/}}
{{- define "rasa.endpoints.models.enabled" -}}
{{- if .Values.rasa.settings.endpoints.models.enabled -}}
{{- print "true" -}}
{{- else -}}
{{- print "false" -}}
{{- end -}}
{{- end -}}

{{/*
Determine if Tracker Store is used
*/}}
{{- define "rasa.endpoints.trackerStore.enabled" -}}
{{- if .Values.rasa.settings.endpoints.trackerStore.enabled -}}
{{- print "true" -}}
{{- else -}}
{{- print "false" -}}
{{- end -}}
{{- end -}}

{{/*
Determine if Lock Store is used
*/}}
{{- define "rasa.endpoints.lockStore.enabled" -}}
{{- if .Values.rasa.settings.endpoints.lockStore.enabled  -}}
{{- print "true" -}}
{{- else -}}
{{- print "false" -}}
{{- end -}}
{{- end -}}


{{/*
Determine if Lock Store is used
*/}}
{{- define "rasa.endpoints.eventBroker.enabled" -}}
{{- if .Values.rasa.settings.endpoints.eventBroker.enabled  -}}
{{- print "true" -}}
{{- else -}}
{{- print "false" -}}
{{- end -}}
{{- end -}}

{{/*
Determine if credential configuration for channel connectors is used
*/}}
{{- define "rasa.credentials.enabled" -}}
{{- if .Values.rasa.settings.credentials.enabled  -}}
{{- print "true" -}}
{{- else -}}
{{- print "false" -}}
{{- end -}}
{{- end -}}

{{/*
Determine if a initial model should be downloaded
*/}}
{{- define "rasa.initialModel.download" -}}
{{- if and (not .Values.rasa.settings.endpoints.models.enabled) (not (empty .Values.rasa.settings.initialModel)) (not .Values.rasa.settings.trainInitialModel) -}}
{{- print "true" -}}
{{- else -}}
{{- print "false" -}}
{{- end -}}
{{- end -}}

{{/*
Determine if a initial model should be trained
*/}}
{{- define "rasa.initialModel.train" -}}
{{- if and (not .Values.rasa.settings.endpoints.models.enabled) .Values.rasa.settings.trainInitialModel -}}
{{- print "true" -}}
{{- else -}}
{{- print "false" -}}
{{- end -}}
{{- end -}}
