{{- define "kafkaMode" }}
{{- if .Values.kafka.standalone }}
{{- printf "Kafka Standalone"}}
{{- else }}
{{- printf "Kafka Cluster" }}
{{- end }}
{{- end }}
