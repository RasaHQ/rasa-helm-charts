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
{{ if .Values.global.additionalDeploymentLabels -}}
{{- $.Values.global.additionalDeploymentLabels | toYaml -}}
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
Selector labels for Model Training Service
*/}}
{{- define "modelTrainingService.selectorLabels" -}}
app.kubernetes.io/name: model-training-service
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: model-training-service-orchestrator
{{- end }}

{{/*
Selector labels for Model Running Service
*/}}
{{- define "modelRunningService.selectorLabels" -}}
app.kubernetes.io/name: model-running-service
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: model-running-service-orchestrator
{{- end }}

{{/*
Selector labels for Nginx Proxy
*/}}
{{- define "nginx.selectorLabels" -}}
app.kubernetes.io/name: nginx-reverse-proxy
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
Create the name of the rasapro service account to use for rasaspro
*/}}
{{- define "studio.rasapro.serviceAccountName" -}}
{{- if .Values.rasapro.serviceAccount.create }}
{{- default (include "studio.fullname" .) .Values.rasapro.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.rasapro.serviceAccount.name }}
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
Create the name of the service account to use for Model Training Service
*/}}
{{- define "modelTrainingService.serviceAccountName" -}}
{{- if .Values.modelService.training.serviceAccount.create }}
{{- default "model-training-service" .Values.modelService.training.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.modelService.training.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use for Model Training Service
*/}}
{{- define "modelRunningService.serviceAccountName" -}}
{{- if .Values.modelService.running.serviceAccount.create }}
{{- default "model-running-service" .Values.modelService.running.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.modelService.running.serviceAccount.name }}
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

{{/*
Return image repository with tag and image name for Rasapro
*/}}
{{- define "studio.rasapro.image" -}}
{{- if hasSuffix "/" .Values.rasapro.image.repository -}}
"{{ .Values.rasapro.image.repository }}{{ .Values.rasapro.image.name }}:{{ .Values.tag }}"
{{- else -}}
"{{ .Values.rasapro.image.repository }}/{{ .Values.rasapro.image.name }}:{{ .Values.tag }}"
{{- end -}}
{{- end -}}

{{/*
Return image repository with tag and image name for Model Training Service
*/}}
{{- define "modelTrainingService.consumer.image" -}}
{{- if hasSuffix "/" .Values.modelService.repository -}}
"{{ .Values.modelService.repository }}{{ .Values.modelService.training.consumer.image.name }}:{{ .Values.modelService.tag }}"
{{- else -}}
"{{ .Values.modelService.repository }}/{{ .Values.modelService.training.consumer.image.name }}:{{ .Values.modelService.tag }}"
{{- end -}}
{{- end -}}

{{/*
Return image repository with tag and image name for Model Training Service
*/}}
{{- define "modelTrainingService.orchestrator.image" -}}
{{- if hasSuffix "/" .Values.modelService.repository -}}
"{{ .Values.modelService.repository }}{{ .Values.modelService.training.orchestrator.image.name }}:{{ .Values.modelService.tag }}"
{{- else -}}
"{{ .Values.modelService.repository }}/{{ .Values.modelService.training.orchestrator.image.name }}:{{ .Values.modelService.tag }}"
{{- end -}}
{{- end -}}

{{/*
Return image repository with tag and image name for Model Running Service
*/}}
{{- define "modelRunningService.consumer.image" -}}
{{- if hasSuffix "/" .Values.modelService.repository -}}
"{{ .Values.modelService.repository }}{{ .Values.modelService.running.consumer.image.name }}:{{ .Values.modelService.tag }}"
{{- else -}}
"{{ .Values.modelService.repository }}/{{ .Values.modelService.running.consumer.image.name }}:{{ .Values.modelService.tag }}"
{{- end -}}
{{- end -}}

{{/*
Return image repository with tag and image name for Model Running Service
*/}}
{{- define "modelRunningService.orchestrator.image" -}}
{{- if hasSuffix "/" .Values.modelService.repository -}}
"{{ .Values.modelService.repository }}{{ .Values.modelService.running.orchestrator.image.name }}:{{ .Values.modelService.tag }}"
{{- else -}}
"{{ .Values.modelService.repository }}/{{ .Values.modelService.running.orchestrator.image.name }}:{{ .Values.modelService.tag }}"
{{- end -}}
{{- end -}}

{{/*
GCP credential volume
*/}}
{{- define "gcpCredentials.volumeMount" -}}
{{- if not (empty .Values.modelService.gcpCredentials.secretName) -}}
- mountPath: "/config/gcloud/"
  name: "gcp-auth"
  readOnly: true
{{- end -}}
{{- end -}}

{{/*
GCP credential volume mount
*/}}
{{- define "gcpCredentials.volume" -}}
{{- if not (empty .Values.modelService.gcpCredentials.secretName) -}}
- name: "gcp-auth"
  secret:
    secretName: {{ .Values.modelService.gcpCredentials.secretName }}
    items:
    - key: {{ .Values.modelService.gcpCredentials.secretKey }}
      path: credentials.json
{{- end -}}
{{- end -}}
