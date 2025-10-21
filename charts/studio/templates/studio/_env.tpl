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
{{- with .Values.config.keycloak }}
- name: KEYCLOAK_REALM
  value: {{ .realm | quote }}
- name: KEYCLOAK_CLIENT_ID
  value: {{ .clientId | quote }}
- name: KEYCLOAK_API_CLIENT_ID
  value: {{ .apiClientId | quote }}
- name: KEYCLOAK_API_USERNAME
  value: {{ .apiUsername | quote }}
- name: KEYCLOAK_API_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .apiPassword.secretName | quote }}
      key: {{ .apiPassword.secretKey | quote }}
{{- end }}
{{- end -}}

{{/*
Backend Database Environment Variables
*/}}
{{- define "studio.backend.env" -}}
{{- with .Values.config.database }}
- name: DB_USER
  value: {{ .username | quote }}
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
  value: {{ .backendDatabaseName | quote }}
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
