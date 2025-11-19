{{/*
Environment Variables for Rasa Containers
*/}}
{{- define "rasa.containers.env" -}}
- name: RASA_PRO_LICENSE 
  valueFrom:
    secretKeyRef:
      name: {{ .Values.rasaProLicense.secretName }}
      key: {{ .Values.rasaProLicense.secretKey }}
{{- with .Values.rasa.settings }}
{{- if or $.Values.duckling.enabled (not (empty $.Values.rasa.settings.ducklingHttpUrl)) -}}
- name: RASA_DUCKLING_HTTP_URL
  value: "{{ include "rasa.ducklingUrl" $ }}"
{{- end }}
{{- if .authToken }}
- name: AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ .authToken.secretName }}
      key: {{ .authToken.secretKey }}
{{- end }}
{{- if .jwtSecret }}
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .jwtSecret.secretName }}
      key: {{ .jwtSecret.secretKey }}
{{- end }}
{{- if .jwtMethod }}
- name: JWT_METHOD
  value: {{ .jwtMethod | quote }}
{{- end }}
{{- if or $.Values.rasaProServices.enabled $.Values.rasa.enabled }}
- name: RASA_TELEMETRY_ENABLED
  value: {{ .telemetry.enabled | quote }}
- name: RASA_TELEMETRY_DEBUG
  value: {{ .telemetry.debug | quote }}
- name: LOG_LEVEL
  value: {{ .logging.logLevel | quote | upper }}
{{- end }}
{{- if $.Values.rasa.enabled }}
- name: RASA_ENVIRONMENT
  value: {{ .environment | quote }}
{{- end }}
{{- end }}
{{- if .Values.rasa.additionalEnv }}
{{ toYaml .Values.rasa.additionalEnv }}
{{- end }}
{{- end -}}

{{/*
Environment Variables for Rasa Analytics
*/}}
{{- define "analytics.env" -}}
- name: LOGGING_LEVEL
  value: {{ .Values.rasaProServices.loggingLevel | quote }}
{{- with .Values.rasaProServices.useCloudProviderIam }}
{{- if .enabled }}
- name: IAM_CLOUD_PROVIDER
  value: {{ .provider | quote }}
- name: AWS_DEFAULT_REGION
  value: {{ .region | quote }}
{{- end }}
{{- end }}
{{- with .Values.rasaProServices.database }}
{{- if .enableAwsRdsIam }}
- name: RDS_SQL_DB_AWS_IAM_ENABLED
  value: "true"
- name: RASA_ANALYTICS_DB_HOST_NAME
  value: {{ .hostname | quote }}
- name: RASA_ANALYTICS_DB_NAME
  value: {{ .databaseName | quote }}
- name: RASA_ANALYTICS_DB_USERNAME
  value: {{ .username | quote }}
- name: RASA_ANALYTICS_DB_PORT
  value: {{ .port | quote }}
- name: RASA_ANALYTICS_DB_SSL_MODE
  value: {{ .sslMode | quote }}
- name: RASA_ANALYTICS_DB_SSL_CA_LOCATION
  value: {{ .sslCaLocation | quote }}
{{- else }}
- name: RASA_ANALYTICS_DB_URL
  value: {{ .url | quote }}
{{- end }}
{{- end }}

{{- with .Values.rasaProServices.kafka }}
{{- if .enableAwsMskIam }}
- name: KAFKA_MSK_AWS_IAM_ENABLED
  value: "true"
{{- end }}
- name: KAFKA_BROKER_ADDRESS
  value: {{ .brokerAddress | quote }}
- name: KAFKA_TOPIC
  value: {{ .topic | quote }}
- name: RASA_ANALYTICS_DLQ
  value: {{ .dlqTopic | quote }}
{{- if .saslMechanism }}
- name: KAFKA_SASL_MECHANISM
  value: {{ .saslMechanism | quote }}
{{- end }}
- name: KAFKA_SECURITY_PROTOCOL
  value: {{ .securityProtocol | quote }}
{{- if .sslCaLocation }}
- name: KAFKA_SSL_CA_LOCATION
  value: {{ .sslCaLocation | quote }}
{{- end }}
{{- if .sslCertFileLocation }}
- name: KAFKA_SSL_CERTFILE_LOCATION
  value: {{ .sslCertFileLocation | quote }}
{{- end }}
{{- if .sslKeyFileLocation }}
- name: KAFKA_SSL_KEYFILE_LOCATION
  value: {{ .sslKeyFileLocation | quote }}
{{- end }}
- name: RASA_ANALYTICS_CONSUMER_ID
  value: {{ .consumerId | quote }}
{{- if and (not .enableAwsMskIam) .saslMechanism }}
- name: KAFKA_SASL_USERNAME
  value: {{ .saslUsername | quote }}
- name: KAFKA_SASL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .saslPassword.secretName }}
      key: {{ .saslPassword.secretKey }}
{{- end }}
{{- end }}
{{- end -}}
