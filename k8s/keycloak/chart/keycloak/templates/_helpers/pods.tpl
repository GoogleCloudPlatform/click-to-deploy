{{- define "keycloak.image" }}
image: {{ .Values.keycloak.image.repo }}:{{ .Values.keycloak.image.tag }}
imagePullPolicy: IfNotPresent
securityContext:
  runAsUser: 1000
  runAsNonRoot: true
{{- end }}

{{- define "keycloak.init_container.check_db" }}
- name: check-db
  image: busybox:1.35
  imagePullPolicy: IfNotPresent
  command:
    - sh
    - -c
    - |
      echo 'Waiting for PostgreSQL to become ready...'
      until printf "." && nc -z -w 2 "{{ .Release.Name }}-postgresql-svc" 5432; do
        sleep 2;
      done;
      echo 'PostgreSQL is ready'
{{- end }}

{{- define "keycloak.envFrom" }}
- secretRef:
    name: {{ .Release.Name }}-config-envs
{{- end }}

{{- define "keycloak.env" }}
- name: KC_DB_URL
  value: "jdbc:postgresql://{{ .Release.Name }}-postgresql-svc:5432/keycloak"
- name: KC_DB_USERNAME
  value: "keycloak"
- name: KEYCLOAK_ADMIN
  value: "admin"
- name: KC_PROXY
  value: "edge"
- name: KC_HOSTNAME_STRICT
  value: "false"
- name: KC_HOSTNAME_STRICT_HTTPS
  value: "false"
- name: KC_HTTP_ENABLED
  value: "true"
- name: KC_HEALTH_ENABLED
  value: "true"
- name: KC_METRICS_ENABLED
  {{- if .Values.metrics.exporter.enabled }}
  value: "true"
  {{- else }}
  value: "false"
  {{- end }}
{{- end }}
