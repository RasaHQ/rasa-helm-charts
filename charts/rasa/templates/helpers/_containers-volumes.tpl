{{- define "rasa.containers.volumes" -}}
{{- if .Values.rasa.mountDefaultConfigmap -}}
{{- if include "rasa.hasIntegrations" . }}
- name: "rasa-configuration"
  configMap:
    name: {{ include "rasa.fullname" . }}-configmap
    items:
      - key: "integrations"
        path: "integrations.yml"
{{- end }}
{{- end }}
{{ if .Values.mountModelsVolume -}}
- name: models
  emptyDir: {}
{{- end }}
{{ if .Values.containerSecurityContext.readOnlyRootFilesystem -}}
{{- /*
An immutable root filesystem still has to let Rasa write three paths: /tmp,
which the image declares as a VOLUME but Kubernetes ignores, and $HOME/.config
and $HOME/.cache for the global config and the matplotlib cache. Each was found
by turning the flag on and reading the resulting errno 30. The project directory
itself needs no write access, so it is deliberately not mounted over.
*/}}
- name: writable-tmp
  emptyDir: {}
- name: writable-dot-config
  emptyDir: {}
- name: writable-dot-cache
  emptyDir: {}
{{- end }}
{{ if .Values.persistence.create -}}
- name: model-data
  persistentVolumeClaim:
    claimName: rasa-pro-data-pvc-{{ .Release.Namespace }}
{{- end -}}
{{- end -}}

{{- define "rasa.containers.volumeMounts" -}}
{{- if .Values.rasa.mountDefaultConfigmap -}}
{{- if include "rasa.hasIntegrations" . }}
- mountPath: "/app/integrations.yml"
  subPath: "integrations.yml"
  name: "rasa-configuration"
  readOnly: true
{{- end }}
{{- end }}
{{ if .Values.mountModelsVolume -}}
- name: "models"
  mountPath: "/app/models"
{{- end }}
{{ if .Values.containerSecurityContext.readOnlyRootFilesystem -}}
- name: "writable-tmp"
  mountPath: "/tmp"
- name: "writable-dot-config"
  mountPath: "/app/.config"
- name: "writable-dot-cache"
  mountPath: "/app/.cache"
{{- end }}
{{ if .Values.persistence.create -}}
- mountPath: "/app/working-data"
  name: model-data
{{- end -}}
{{- end -}}
