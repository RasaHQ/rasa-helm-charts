{{- define "rasa.containers.volumes" -}}
{{- if .Values.rasa.settings.mountDefaultConfigmap -}}
- name: config-dir
  emptyDir: {}
- name: "rasa-configuration"
  configMap:
    name: {{ include "rasa.fullname" . }}-configmap
    items:
      - key: "endpoints"
        path: "endpoints.yml"
      - key: "credentials"
        path: "credentials.yml"
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
- name: "config-dir"
  mountPath: "/.config"
- mountPath: "/app/endpoints.yml"
  subPath: "endpoints.yml"
  name: "rasa-configuration"
  readOnly: true
- mountPath: "/app/credentials.yml"
  subPath: "credentials.yml"
  name: "rasa-configuration"
  readOnly: true
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
