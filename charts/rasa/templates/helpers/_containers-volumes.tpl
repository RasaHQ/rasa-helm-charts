{{- define "rasa.containers.volumes" -}}
{{- if .Values.rasa.settings.mountDefaultConfigmap -}}
- name: config-dir
  emptyDir: {}
{{- $hasEndpoints := and .Values.rasa.settings.endpoints (ne (len .Values.rasa.settings.endpoints) 0) }}
{{- $hasCredentials := and .Values.rasa.settings.credentials (ne (len .Values.rasa.settings.credentials) 0) }}
{{- if or $hasEndpoints $hasCredentials }}
- name: "rasa-configuration"
  configMap:
    name: {{ include "rasa.fullname" . }}-configmap
    items:
{{- if $hasEndpoints }}
      - key: "endpoints"
        path: "endpoints.yml"
{{- end }}
{{- if $hasCredentials }}
      - key: "credentials"
        path: "credentials.yml"
{{- end }}
{{- end }}
{{- end }}
{{ if .Values.rasa.settings.mountModelsVolume -}}
- name: models
  emptyDir: {}
{{- end }}
{{ if .Values.rasa.persistence.create -}}
- name: model-data
  persistentVolumeClaim:
    claimName: rasa-pro-data-pvc-{{ .Release.Namespace }}
{{- end -}}
{{- end -}}

{{- define "rasa.containers.volumeMounts" -}}
{{- if .Values.rasa.settings.mountDefaultConfigmap -}}
{{- $hasEndpoints := and .Values.rasa.settings.endpoints (ne (len .Values.rasa.settings.endpoints) 0) }}
{{- $hasCredentials := and .Values.rasa.settings.credentials (ne (len .Values.rasa.settings.credentials) 0) }}
{{- if or $hasEndpoints $hasCredentials }}
- name: "config-dir"
  mountPath: "/.config"
{{- end }}
{{- if $hasEndpoints }}
- mountPath: "/app/endpoints.yml"
  subPath: "endpoints.yml"
  name: "rasa-configuration"
  readOnly: true
{{- end }}
{{- if $hasCredentials }}
- mountPath: "/app/credentials.yml"
  subPath: "credentials.yml"
  name: "rasa-configuration"
  readOnly: true
{{- end }}
{{- end }}
{{ if .Values.rasa.settings.mountModelsVolume -}}
- name: "models"
  mountPath: "/app/models"
{{- end }}
{{ if .Values.rasa.persistence.create -}}
- mountPath: "/app/working-data"
  name: model-data
{{- end -}}
{{- end -}}
