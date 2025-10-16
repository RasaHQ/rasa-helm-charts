{{/*
Environment Variables for Studio between Keycloak and Backend
*/}}
{{- define "studio.shared.env" -}}
- name: KEYCLOAK_ADMIN
  value: {{ .Values.config.keycloak.adminUsername | quote }}
- name: KEYCLOAK_ADMIN_USERNAME
  value: {{ .Values.config.keycloak.adminUsername | quote }}
# -- The password for the Keycloak admin user. This credential is used to manage users and clients in Keycloak.
- name: KEYCLOAK_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.keycloak.adminPassword.secretName | quote }}
      key: {{ .Values.config.keycloak.adminPassword.secretKey | quote }}
{{- end -}}

{{/*
Environment Variables for Keycloak Containers
*/}}
{{- define "studio.keycloak.env" -}}
- name: KC_DB_USERNAME
  {{- if not (empty .Values.keycloak.database.username) }}
  value: {{ .Values.keycloak.database.username | quote }}
  {{- else }}
  value: {{ .Values.config.database.username | quote }}
  {{- end }}
- name: KC_DB_PASSWORD
  {{- if not (empty .Values.keycloak.database.password) }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.keycloak.database.password.secretName | quote }}
      key: {{ .Values.keycloak.database.password.secretKey | quote }}  
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.password.secretName | quote }}
      key: {{ .Values.config.database.password.secretKey | quote }}
  {{- end }}
- name: KC_DB_URL
  value: "jdbc:postgresql://{{ default .Values.config.database.host .Values.keycloak.database.host }}:{{ default .Values.config.database.port .Values.keycloak.database.port }}/{{ default .Values.config.database.keycloakDatabaseName .Values.keycloak.database.databaseName }}"
{{- end -}}

{{/*
Keycloak URL
*/}}
{{- define "studio.keycloak.url" -}}
{{- if not (empty .Values.config.keycloak.url ) -}}
- name: KEYCLOAK_URL
  value: {{ .Values.config.keycloak.url }}
{{- else -}}
- name: KEYCLOAK_URL
  value: "http://{{ include "studio.fullname" . }}-keycloak/auth"
{{- end -}}
{{- end -}}

{{/*
Backend Keycloak env
*/}}
{{- define "studio.backend.keycloak" -}}
- name: KEYCLOAK_REALM
  value: {{ .Values.config.keycloak.realm | quote }}
- name: KEYCLOAK_CLIENT_ID
  value: {{ .Values.config.keycloak.clientId | quote }}
- name: KEYCLOAK_API_CLIENT_ID
  value: {{ .Values.config.keycloak.apiClientId | quote }}
- name: KEYCLOAK_API_USERNAME
  value: {{ .Values.config.keycloak.apiUsername | quote }}
- name: KEYCLOAK_API_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.keycloak.apiPassword.secretName | quote }}
      key: {{ .Values.config.keycloak.apiPassword.secretKey | quote }}
{{- end -}}

{{/*
Backend Database Environment Variables
*/}}
{{- define "studio.backend.env" -}}
- name: DB_USER
  value: {{ .Values.config.database.username | quote }}
{{- if ne (.Values.config.database.useAwsIamAuth | toString) "true" }}
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.password.secretName | quote }}
      key: {{ .Values.config.database.password.secretKey | quote }}
{{- end }}
- name: DB_HOST
  value: {{ .Values.config.database.host | quote }}
- name: DB_PORT
  value: {{ .Values.config.database.port | quote }}
- name: DB_NAME
  value: {{ .Values.config.database.backendDatabaseName | quote }}
- name: DB_QUERY
  value: {{ .Values.config.database.queryParams | quote }}
- name: AWS_REGION
  value: {{ .Values.config.database.awsRegion | quote }}
- name: IAM_DB_USERNAME
  value: {{ .Values.config.database.iamDbUsername | quote }}
- name: USE_AWS_IAM_AUTH
  value: {{ .Values.config.database.useAwsIamAuth | quote }}
{{- end -}}
