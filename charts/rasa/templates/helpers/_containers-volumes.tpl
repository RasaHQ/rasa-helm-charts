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
- name: models
  emptyDir: {}
- name: app-dir
  emptyDir: {}
{{- end }}
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
{{- end -}}
