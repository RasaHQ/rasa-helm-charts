{{/*
Environment Variables for Rasa Containers
*/}}
{{- define "rasa.containers.env" -}}
{{- with .Values.rasa }}
{{- if .authToken }}
- name: "AUTH_TOKEN"
  valueFrom:
    secretKeyRef:
      name: {{ .authToken.secretName }}
      key: {{ .authToken.secretKey }}
{{- end }}
{{- if .jwtSecret }}
- name: "JWT_SECRET"
  valueFrom:
    secretKeyRef:
      name: {{ .jwtSecret.secretName }}
      key: {{ .jwtSecret.secretKey }}
{{- end }}
{{- if .jwtMethod }}
- name: "JWT_METHOD"
  value: {{ .jwtMethod | quote }}
{{- end }}
# Rasa Pro License
- name: "RASA_PRO_LICENSE"
  valueFrom:
    secretKeyRef:
      name: {{ $.Values.rasaProLicense.secretName }}
      key: {{ $.Values.rasaProLicense.secretKey }}
# Telemetry
- name: "RASA_TELEMETRY_ENABLED"
  value: {{ .telemetry.enabled | quote }}
- name: "RASA_TELEMETRY_DEBUG"
  value: {{ .telemetry.debug | quote }}
# Logging
- name: "LOG_LEVEL"
  value: {{ .logging.logLevel | quote | upper }}
- name: "RASA_ENVIRONMENT"
  value: {{ .environment | quote }}
{{- end }}
{{- if .Values.rasa.extraEnv }}
{{ toYaml .Values.rasa.extraEnv }}
{{- end }}
{{- end -}}
