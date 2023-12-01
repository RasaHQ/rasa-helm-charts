{{/*
Environment Variables shared between MTS and MRS
*/}}
{{- define "modelService.shared.env" -}}
- name: KUBERNETES_NAMESPACE
  value: {{ .Release.Namespace | quote }}
{{- with .Values.modelService }}
- name: RUNS_IN_CLUSTER
  value: {{ .runsInCluster | quote }}
- name: ENABLE_AUTHORIZATION
  value: {{ .keycloak.enableAuthorization | quote }}
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
{{- end }}
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
{{- end }}
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
