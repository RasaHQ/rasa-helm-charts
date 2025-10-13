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
  {{- if and .Values.config.keycloak.database .Values.config.keycloak.database.username }}
  value: {{ .Values.config.keycloak.database.username | quote }}
  {{- else }}
  value: {{ .Values.config.database.username | quote }}
  {{- end }}
- name: KC_DB_PASSWORD
  {{- if and .Values.config.keycloak.database .Values.config.keycloak.database.password }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.keycloak.database.password.secretName | quote }}
      key: {{ .Values.config.keycloak.database.password.secretKey | quote }}  
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.password.secretName | quote }}
      key: {{ .Values.config.database.password.secretKey | quote }}
  {{- end }}
- name: KC_DB_URL
  # jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
  {{- if and .Values.config.keycloak.database .Values.config.keycloak.database.host .Values.config.keycloak.database.port .Values.config.keycloak.database.databaseName }}
  value: "jdbc:postgresql://{{ .Values.config.keycloak.database.host }}:{{ .Values.config.keycloak.database.port }}/{{ .Values.config.keycloak.database.databaseName }}"
  {{- else }}
  value: "jdbc:postgresql://{{ .Values.config.database.host }}:{{ .Values.config.database.port }}/{{ .Values.config.database.keycloakDatabaseName }}"
  {{- end }}
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
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.password.secretName | quote }}
      key: {{ .Values.config.database.password.secretKey | quote }}
- name: DB_HOST
  value: {{ .Values.config.database.host | quote }}
- name: DB_PORT
  value: {{ .Values.config.database.port | quote }}
- name: DB_NAME
  value: {{ .Values.config.database.backendDatabaseName | quote }}
- name: DB_QUERY
  value: {{ .Values.config.database.queryParams | quote }}
{{- end -}}
