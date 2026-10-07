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
Database Environment Variables

Included by all three database clients: the app Deployment, the standalone
event-ingestion Deployment, and the migration Job. Event ingestion is a
first-class client with its own connection pool, not a borrower of the app's
— which is why config.database lives under config: rather than app:.
Keep app-only env in studio.app.*.env helpers instead.
*/}}
{{- define "studio.database.env" -}}
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
  {{- if kindIs "map" .host }}
  valueFrom:
    secretKeyRef:
      name: {{ .host.secretName | quote }}
      key: {{ .host.secretKey | quote }}
  {{- else }}
  value: {{ .host | quote }}
  {{- end }}
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


{{/*
Studio App Initial Admin Environment Variables

Rendered only when `app.initialAdmin.email` is non-empty, so an install that
already has an admin never needs the password Secret key to exist.
App-only: the backend creates the account on startup.
Context is the `app.initialAdmin` map, not the root.
*/}}
{{- define "studio.app.initialAdmin.env" -}}
- name: INITIAL_ADMIN_EMAIL
  value: {{ .email | quote }}
- name: INITIAL_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .password.secretName | quote }}
      key: {{ .password.secretKey | quote }}
{{- end -}}


{{/*
Studio App GitHub App Environment Variables

Caller guards on a non-empty `app.github`; the schema enforces all-or-none, so
every key is present here.
App-only: the migration Job and event-ingestion deployment never read these.
Context is the `app.github` map, not the root.
*/}}
{{- define "studio.app.github.env" -}}
- name: GITHUB_APP_ID
  valueFrom:
    secretKeyRef:
      name: {{ .appId.secretName | quote }}
      key: {{ .appId.secretKey | quote }}
- name: GITHUB_APP_INSTALLATION_ID
  valueFrom:
    secretKeyRef:
      name: {{ .installationId.secretName | quote }}
      key: {{ .installationId.secretKey | quote }}
- name: GITHUB_APP_PRIVATE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .privateKey.secretName | quote }}
      key: {{ .privateKey.secretKey | quote }}
{{- end -}}
