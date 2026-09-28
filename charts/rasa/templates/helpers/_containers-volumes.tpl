{{- define "rasa.containers.volumes" -}}
{{- if .Values.rasa.mountDefaultConfigmap -}}
{{- $hasEndpoints := include "rasa.hasEndpoints" . }}
{{- $hasCredentials := include "rasa.hasCredentials" . }}
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
{{ if .Values.rasa.mountModelsVolume -}}
- name: models
  emptyDir: {}
{{- end }}
{{ if .Values.rasa.containerSecurityContext.readOnlyRootFilesystem -}}
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
{{ if .Values.rasa.persistence.create -}}
- name: model-data
  persistentVolumeClaim:
    claimName: rasa-pro-data-pvc-{{ .Release.Namespace }}
{{- end -}}
{{- end -}}

{{- define "rasa.containers.volumeMounts" -}}
{{- if .Values.rasa.mountDefaultConfigmap -}}
{{- $hasEndpoints := include "rasa.hasEndpoints" . }}
{{- $hasCredentials := include "rasa.hasCredentials" . }}
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
{{ if .Values.rasa.mountModelsVolume -}}
- name: "models"
  mountPath: "/app/models"
{{- end }}
{{ if .Values.rasa.containerSecurityContext.readOnlyRootFilesystem -}}
- name: "writable-tmp"
  mountPath: "/tmp"
- name: "writable-dot-config"
  mountPath: "/app/.config"
- name: "writable-dot-cache"
  mountPath: "/app/.cache"
{{- end }}
{{ if .Values.rasa.persistence.create -}}
- mountPath: "/app/working-data"
  name: model-data
{{- end -}}
{{- end -}}
