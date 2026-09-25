{{/*
Render a native EnvVar list, stringifying scalar values.
Values often arrive as YAML/JSON booleans or numbers (Pulumi YAML coerces
"true"/"false" config strings to booleans; `--set x=true` does the same),
but Kubernetes requires EnvVar.value to be a string — so scalars are
stringified and quoted here. valueFrom entries pass through verbatim.
*/}}
{{- define "studio.envList" -}}
{{- range . }}
- name: {{ .name }}
  {{- if hasKey . "value" }}
  value: {{ .value | toString | quote }}
  {{- end }}
  {{- with .valueFrom }}
  valueFrom:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}





{{/*
Studio App Database Environment Variables
*/}}
{{- define "studio.app.env" -}}
{{- with .Values.config.database }}
- name: DB_USER
  {{- if kindIs "map" .username }}
  valueFrom:
    secretKeyRef:
      name: {{ .username.secretName | quote }}
      key: {{ .username.secretKey | quote }}
  {{- else }}
  value: {{ .username | quote }}
  {{- end }}
{{- if ne (.useAwsIamAuth | toString) "true" }}
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: {{ .password.secretName | quote }}
      key: {{ .password.secretKey | quote }}
{{- end }}
- name: DB_HOST
  value: {{ .host | quote }}
- name: DB_PORT
  value: {{ .port | quote }}
- name: DB_NAME
  {{- if kindIs "map" .databaseName }}
  valueFrom:
    secretKeyRef:
      name: {{ .databaseName.secretName | quote }}
      key: {{ .databaseName.secretKey | quote }}
  {{- else }}
  value: {{ .databaseName | quote }}
  {{- end }}
- name: DB_QUERY
  value: {{ .queryParams | quote }}
{{- if and (not (empty .awsRegion)) (eq (.useAwsIamAuth | toString) "true") }}
- name: AWS_REGION
  value: {{ .awsRegion | quote }}
{{- end }}
{{- if and (not (empty .iamDbUsername)) (eq (.useAwsIamAuth | toString) "true") }}
- name: IAM_DB_USER
  value: {{ .iamDbUsername | quote }}
{{- end }}
{{- if eq (.useAwsIamAuth | toString) "true" }}
- name: USE_AWS_IAM_AUTH
  value: "true"
{{- end }}
{{- end }}
{{- end -}}
