{{/*
Environment Variables shared between MTS and MRS
*/}}
{{- define "modelService.shared.env" -}}
- name: KUBERNETES_NAMESPACE
  value: {{ .Release.Namespace | quote }}
{{- with .Values.modelService }}
- name: RUNS_IN_CLUSTER
  value: {{ .runsInCluster | quote }}
- name: AUTHENTICATION_ENDPOINT_ENABLED
  value: "false"
- name: KAFKA_BROKER_ADDRESS
  value: {{ .kafka.brokerAddress | quote }}
- name: KAFKA_SECURITY_PROTOCOL
  value: {{ .kafka.securityProtocol | quote }}
- name: KAFKA_SASL_MECHANISM
  value: {{ .kafka.saslMechanism | quote }}
- name: KAFKA_SASL_USERNAME
  value: {{ .kafka.saslUsername | quote }}
- name: KAFKA_SASL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .kafka.saslPassword.secretName }}
      key: {{ .kafka.saslPassword.secretKey }}
- name: KAFKA_SSL_CA_LOCATION
  value: {{ .kafka.sslCaLocation | quote }}
- name: RASA_PRO_LICENSE
  valueFrom:
    secretKeyRef:
      name: {{ .rasaProLicense.secretName}}
      key: {{ .rasaProLicense.secretKey}}
- name: STORAGE_TYPE
  value: {{ .storage.type | quote }}
{{- if eq .storage.type "aws_s3" }}
- name: AWS_ACCESS_KEY_ID
  valueFrom:
    secretKeyRef:
      name: {{ .storage.awsSecretAccessKey.secretName | quote }}
      key: {{ .storage.awsSecretAccessKey.secretKey | quote }}
- name: AWS_SECRET_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .storage.awsSecretAccessKey.secretName | quote }}
      key: {{ .storage.awsSecretAccessKey.secretKey | quote }}
- name: REGION_NAME
  value: {{ .storage.regionName | quote }}
{{- end }}
{{- if eq .storage.type "gcs" }}
- name: GOOGLE_CLOUD_PROJECT
  value: {{ .storage.googleCloudProject | quote }}
- name: CLOUDSDK_COMPUTE_ZONE
  value: {{ .storage.cloudskdComputeZone | quote }}
- name: TRAINING_STORAGE_SIGNED_URL_SERVICE_ACCOUNT
  valueFrom:
    secretKeyRef:
      name: {{ .storage.trainingStorageServiceAccount.secretName | quote }}
      key: {{ .storage.trainingStorageServiceAccount.secretKey | quote }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Environment Variables for Model Service Training Orchestrator
*/}}
{{- define "modelServiceTraining.orchestrator.env" -}}
- name: TRAINING_STORAGE_BUCKET
  value: {{ .Values.modelService.storage.bucketName | quote }}
# -- Studio supports only postgres as a database backend
- name: PERSISTOR_BACKEND
  value: "postgres"
- name: POSTGRES_HOST
  value: {{ .Values.config.database.host | quote }}
- name: POSTGRES_PORT
  value: {{ .Values.config.database.port | quote }}
- name: POSTGRES_DATABASE
  value: {{ .Values.config.database.modelServiceDatabaseName | quote }}
- name: POSTGRES_USERNAME
  value: {{ .Values.config.database.username | quote }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.password.secretName | quote }}
      key: {{ .Values.config.database.password.secretKey | quote }}
{{- end -}}

{{/*
Environment Variables for Model Service Training Consumer
*/}}
{{- define "modelServiceTraining.consumer.env" -}}
{{- with .Values.modelService }}
- name: KUBERNETES_DATA_PVC
  value: "model-training-service-data-pvc-{{ $.Release.Namespace }}"
- name: RASA_PRO_LICENSE_SECRET_NAME
  value: {{ .rasaProLicense.secretName | quote }}
- name: RASA_PRO_LICENSE_SECRET_KEY
  value: {{ .rasaProLicense.secretKey | quote }}
- name: OPENAI_API_KEY_SECRET_NAME
  value: {{ .openAiKey.secretName | quote }}
- name: OPENAI_API_KEY_SECRET_KEY
  value: {{ .openAiKey.secretKey | quote }}
- name: BUCKET_NAME
  value: {{ .storage.bucketName | quote }}
{{- end }}
{{- end -}}

{{/*
Environment Variables for Model Service Running Orchestrator
*/}}
{{- define "modelServiceRunning.orchestrator.env" -}}
- name: DEPLOYMENT_STORAGE_BUCKET
  value: {{ .Values.modelService.storage.bucketName | quote }}
# -- Studio supports only postgres as a database backend
- name: PERSISTOR_BACKEND
  value: "postgres"
- name: POSTGRES_HOST
  value: {{ .Values.config.database.host | quote }}
- name: POSTGRES_PORT
  value: {{ .Values.config.database.port | quote }}
- name: POSTGRES_DATABASE
  value: {{ .Values.config.database.modelServiceDatabaseName | quote }}
- name: POSTGRES_USERNAME
  value: {{ .Values.config.database.username | quote }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.database.password.secretName | quote | quote }}
      key: {{ .Values.config.database.password.secretKey | quote }}
{{- end -}}

{{/*
Environment Variables for Model Service Running Consumer
*/}}
{{- define "modelServiceRunning.consumer.env" -}}
{{- with .Values.modelService }}
- name: KUBERNETES_DATA_PVC
  value: "model-running-service-data-pvc-{{ $.Release.Namespace }}"
- name: RASA_PRO_LICENSE_SECRET_NAME
  value: {{ .rasaProLicense.secretName | quote }}
- name: RASA_PRO_LICENSE_SECRET_KEY
  value: {{ .rasaProLicense.secretKey | quote }}
- name: OPENAI_API_KEY_SECRET_NAME
  value: {{ .openAiKey.secretName | quote }}
- name: OPENAI_API_KEY_SECRET_KEY
  value: {{ .openAiKey.secretKey | quote }}
- name: BUCKET_NAME
  value: {{ .storage.bucketName | quote }}
{{- end }}
{{- with .Values.modelService.running.consumer }}
- name: RASA_READINESS_CHECK_INITIAL_DELAY_SECONDS
  value: {{ .rasaReadinessProbe.initialDelaySeconds | quote}}
- name: RASA_READINESS_CHECK_INTERVAL_IN_SECONDS
  value: {{ .rasaReadinessProbe.intervalInSeconds | quote }}
- name: RASA_READINESS_FAILURE_THRESHOLD
  value: {{ .rasaReadinessProbe.failureThreshold | quote }}
- name: RASA_STARTUP_CHECK_INITIAL_DELAY_SECONDS
  value: {{ .rasaStartupProbe.initialDelaySeconds | quote }}
- name: RASA_STARTUP_CHECK_INTERVAL_IN_SECONDS
  value: {{ .rasaStartupProbe.intervalInSeconds | quote }}
- name: RASA_STARTUP_FAILURE_THRESHOLD
  value: {{ .rasaStartupProbe.failureThreshold | quote }}
{{- end }}
{{- end -}}
