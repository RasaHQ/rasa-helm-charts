{{/*
Environment Variables for Rasa Containers
*/}}
{{- define "rasa.containers.env" -}}
{{- with .Values.rasa.settings }}
{{- if or $.Values.duckling.enabled (not (empty $.Values.rasa.settings.ducklingHttpUrl)) -}}
- name: "RASA_DUCKLING_HTTP_URL"
  value: "{{ include "rasa.ducklingUrl" $ }}"
{{- end }}
- name: "AUTH_TOKEN"
  valueFrom:
    secretKeyRef:
      name: {{ .authToken.secretName }}
      key: {{ .authToken.secretKey }}
- name: "JWT_SECRET"
  valueFrom:
    secretKeyRef:
      name: {{ .jwtSecret.secretName }}
      key: {{ .jwtSecret.secretKey }}
- name: "JWT_METHOD"
  value: {{ .jwtMethod | quote }}
# Rasa Pro License
{{- if or $.Values.rasaProServices.enabled $.Values.rasa.enabled }}
- name: "RASA_PRO_LICENSE" 
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.rasaProLicense.secretName }}
      key: {{ $.Values.rasaProLicense.secretKey }}
{{- end }}
{{- if or $.Values.rasaProServices.enabled $.Values.rasa.enabled }}
# Telemetry
- name: "RASA_TELEMETRY_ENABLED"
  value: {{ .telemetry.enabled | quote }}
- name: "RASA_TELEMETRY_DEBUG"
  value: {{ .telemetry.debug | quote }}
# Logging
- name: "LOG_LEVEL"
  value: {{ .logging.logLevel | quote | upper }}
{{- end }}
{{- if $.Values.rasa.enabled }}
- name: "RASA_ENVIRONMENT"
  value: {{ .environment | quote }}
{{- end }}
{{- end }}
{{- if .Values.rasa.additionalEnv }}
{{ toYaml .Values.rasa.additionalEnv }}
{{- end }}
{{- end -}}
