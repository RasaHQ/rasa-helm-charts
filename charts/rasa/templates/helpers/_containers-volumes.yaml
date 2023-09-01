{{- define "rasa.containers.volumes" -}}
- name: config-dir
  emptyDir: {}
- name: "rasa-configuration"
  configMap:
    name: rasa-configmap
    items:
      - key: "endpoints"
        path: "endpoints.yml"
      - key: "credentials"
        path: "credentials.yml"
- name: models
  emptyDir: {}
- name: app-dir
  emptyDir: {}
{{- end -}}

{{- define "rasa.containers.volumeMounts" -}}
# Mount the temporary directory for the Rasa global configuration
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
{{- end -}}
