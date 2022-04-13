{{/* Checks for `.Release.name` */}}
{{- if gt (len .Release.Name) 43 }}
  {{ required "The `.Release.name` must be less than 43 characters (due to the 63 character limit for names in Kubernetes)!" nil }}
{{- end }}

{{/* Checks for `airflow.legacyCommands` */}}
{{- if .Values.airflow.legacyCommands }}
  {{- if not (eq "1" (.Values.scheduler.replicas | toString)) }}
  {{ required "If `airflow.legacyCommands=true`, then `scheduler.replicas` must be set to `1`!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for `airflow.image` */}}
{{- if eq .Values.airflow.image.repository "apache/airflow" }}
  {{- if hasPrefix "1." .Values.airflow.image.tag }}
    {{- if not .Values.airflow.legacyCommands }}
    {{ required "When using airflow 1.10.X, `airflow.legacyCommands` must be `true`!" nil }}
    {{- end }}
  {{ end }}
  {{- if hasPrefix "2." .Values.airflow.image.tag }}
    {{- if .Values.airflow.legacyCommands }}
    {{ required "When using airflow 2.X.X, `airflow.legacyCommands` must be `false`!" nil }}
    {{- end }}
  {{ end }}
{{- end }}

{{/* Checks for `airflow.executor` */}}
{{- if not (has .Values.airflow.executor (list "CeleryExecutor" "CeleryKubernetesExecutor" "KubernetesExecutor")) }}
  {{ required "The `airflow.executor` must be one of: [CeleryExecutor, CeleryKubernetesExecutor, KubernetesExecutor]!" nil }}
{{- end }}
{{- if eq .Values.airflow.executor "CeleryExecutor" }}
  {{- if not .Values.workers.enabled }}
  {{ required "If `airflow.executor=CeleryExecutor`, then `workers.enabled` should be `true`!" nil }}
  {{- end }}
{{- end }}
{{- if eq .Values.airflow.executor "CeleryKubernetesExecutor" }}
  {{- if not .Values.workers.enabled }}
  {{ required "If `airflow.executor=CeleryKubernetesExecutor`, then `workers.enabled` should be `true`!" nil }}
  {{- end }}
{{- end }}
{{- if eq .Values.airflow.executor "KubernetesExecutor" }}
  {{- if or (.Values.workers.enabled) (.Values.flower.enabled) (.Values.redis.enabled) }}
  {{ required "If `airflow.executor=KubernetesExecutor`, then all of [`workers.enabled`, `flower.enabled`, `redis.enabled`] should be `false`!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for `airflow.config` */}}
{{- if .Values.airflow.config.AIRFLOW__CORE__EXECUTOR }}
  {{ required "Don't define `airflow.config.AIRFLOW__CORE__EXECUTOR`, it will be automatically set from `airflow.executor`!" nil }}
{{- end }}
{{- if or .Values.airflow.config.AIRFLOW__CORE__DAGS_FOLDER }}
  {{ required "Don't define `airflow.config.AIRFLOW__CORE__DAGS_FOLDER`, it will be automatically set from `dags.path`!" nil }}
{{- end }}
{{- if or (.Values.airflow.config.AIRFLOW__CELERY__BROKER_URL) (.Values.airflow.config.AIRFLOW__CELERY__BROKER_URL_CMD) }}
  {{ required "Don't define `airflow.config.AIRFLOW__CELERY__BROKER_URL`, it will be automatically set by the chart!" nil }}
{{- end }}
{{- if or (.Values.airflow.config.AIRFLOW__CELERY__RESULT_BACKEND) (.Values.airflow.config.AIRFLOW__CELERY__RESULT_BACKEND_CMD) }}
  {{ required "Don't define `airflow.config.AIRFLOW__CELERY__RESULT_BACKEND`, it will be automatically set by the chart!" nil }}
{{- end }}
{{- if or (.Values.airflow.config.AIRFLOW__CORE__SQL_ALCHEMY_CONN) (.Values.airflow.config.AIRFLOW__CORE__SQL_ALCHEMY_CONN_CMD) }}
  {{ required "Don't define `airflow.config.AIRFLOW__CORE__SQL_ALCHEMY_CONN`, it will be automatically set by the chart!" nil }}
{{- end }}

{{/* Checks for `logs.persistence` */}}
{{- if .Values.logs.persistence.enabled }}
  {{- if not (eq .Values.logs.persistence.accessMode "ReadWriteMany") }}
  {{ required "The `logs.persistence.accessMode` must be `ReadWriteMany`!" nil }}
  {{- end }}
  {{- if .Values.scheduler.logCleanup.enabled }}
  {{ required "If `logs.persistence.enabled=true`, then `scheduler.logCleanup.enabled` must be disabled!" nil }}
  {{- end }}
  {{- if .Values.workers.enabled }}
    {{- if .Values.workers.logCleanup.enabled }}
    {{ required "If `logs.persistence.enabled=true`, then `workers.logCleanup.enabled` must be disabled!" nil }}
    {{- end }}
  {{- end }}
{{- end }}

{{/* Checks for `dags.persistence` */}}
{{- if .Values.dags.persistence.enabled }}
  {{- if not (has .Values.dags.persistence.accessMode (list "ReadOnlyMany" "ReadWriteMany")) }}
  {{ required "The `dags.persistence.accessMode` must be one of: [ReadOnlyMany, ReadWriteMany]!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for `dags.gitSync` */}}
{{- if .Values.dags.gitSync.enabled }}
  {{- if .Values.dags.persistence.enabled }}
  {{ required "If `dags.gitSync.enabled=true`, then `persistence.enabled` must be disabled!" nil }}
  {{- end }}
  {{- if not .Values.dags.gitSync.repo }}
  {{ required "If `dags.gitSync.enabled=true`, then `dags.gitSync.repo` must be non-empty!" nil }}
  {{- end }}
  {{- if and (.Values.dags.gitSync.sshSecret) (.Values.dags.gitSync.httpSecret) }}
  {{ required "At most, one of `dags.gitSync.sshSecret` and `dags.gitSync.httpSecret` can be defined!" nil }}
  {{- end }}
  {{- if and (.Values.dags.gitSync.repo | lower | hasPrefix "git@github.com") (not .Values.dags.gitSync.sshSecret) }}
  {{ required "You must define `dags.gitSync.sshSecret` when using GitHub with SSH for `dags.gitSync.repo`!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for `ingress` */}}
{{- if .Values.ingress.enabled }}
  {{/* Checks for `ingress.apiVersion` */}}
  {{- if not (has .Values.ingress.apiVersion (list "networking.k8s.io/v1" "networking.k8s.io/v1beta1")) }}
  {{ required "The `ingress.apiVersion` must be one of: [networking.k8s.io/v1, networking.k8s.io/v1beta1]!" nil }}
  {{- end }}

  {{/* Checks for `ingress.web.path` */}}
  {{- if .Values.ingress.web.path }}
    {{- if not (.Values.ingress.web.path | hasPrefix "/") }}
    {{ required "The `ingress.web.path` should start with a '/'!" nil }}
    {{- end }}
    {{- if .Values.ingress.web.path | hasSuffix "/" }}
    {{ required "The `ingress.web.path` should NOT include a trailing '/'!" nil }}
    {{- end }}
    {{- if .Values.airflow.config.AIRFLOW__WEBSERVER__BASE_URL }}
      {{- $webUrl := .Values.airflow.config.AIRFLOW__WEBSERVER__BASE_URL | urlParse }}
      {{- if not (eq (.Values.ingress.web.path | trimSuffix "/*") (get $webUrl "path")) }}
      {{ required (printf "The `ingress.web.path` must be compatable with `airflow.config.AIRFLOW__WEBSERVER__BASE_URL`! (try setting AIRFLOW__WEBSERVER__BASE_URL to 'http://{HOSTNAME}%s', rather than '%s')" (.Values.ingress.web.path | trimSuffix "/*") .Values.airflow.config.AIRFLOW__WEBSERVER__BASE_URL) nil }}
      {{- end }}
    {{- else }}
      {{ required (printf "If `ingress.web.path` is set, then `airflow.config.AIRFLOW__WEBSERVER__BASE_URL` must be set! (try setting AIRFLOW__WEBSERVER__BASE_URL to 'http://{HOSTNAME}%s')" (.Values.ingress.web.path | trimSuffix "/*")) nil }}
    {{- end }}
  {{- end }}

  {{/* Checks for `ingress.flower.path` */}}
  {{- if .Values.ingress.flower.path }}
    {{- if not (.Values.ingress.flower.path | hasPrefix "/") }}
    {{ required "The `ingress.flower.path` should start with a '/'!" nil }}
    {{- end }}
    {{- if .Values.ingress.flower.path | hasSuffix "/" }}
    {{ required "The `ingress.flower.path` should NOT include a trailing '/'!" nil }}
    {{- end }}
    {{- if .Values.airflow.config.AIRFLOW__CELERY__FLOWER_URL_PREFIX }}
      {{- if not (eq (.Values.ingress.flower.path | trimSuffix "/*") .Values.airflow.config.AIRFLOW__CELERY__FLOWER_URL_PREFIX) }}
      {{ required (printf "The `ingress.flower.path` must be compatable with `airflow.config.AIRFLOW__CELERY__FLOWER_URL_PREFIX`! (try setting AIRFLOW__CELERY__FLOWER_URL_PREFIX to '%s', rather than '%s')" (.Values.ingress.flower.path | trimSuffix "/*") .Values.airflow.config.AIRFLOW__CELERY__FLOWER_URL_PREFIX) nil }}
      {{- end }}
    {{- else }}
      {{ required (printf "If `ingress.flower.path` is set, then `airflow.config.AIRFLOW__CELERY__FLOWER_URL_PREFIX` must be set! (try setting AIRFLOW__CELERY__FLOWER_URL_PREFIX to '%s')" (.Values.ingress.flower.path | trimSuffix "/*")) nil }}
    {{- end }}
  {{- end }}
{{- end }}

{{/* Checks for `pgbouncer` */}}
{{- if include "airflow.pgbouncer.should_use" . }}
    {{- if .Values.pgbouncer.clientSSL.keyFile.existingSecret }}
        {{- if not .Values.pgbouncer.clientSSL.certFile.existingSecret }}
        {{ required "If `pgbouncer.clientSSL.keyFile.existingSecret` is set, then `pgbouncer.clientSSL.certFile.existingSecret` must also be!" nil }}
        {{- end }}
    {{- end }}
    {{- if .Values.pgbouncer.clientSSL.certFile.existingSecret }}
        {{- if not .Values.pgbouncer.clientSSL.keyFile.existingSecret }}
        {{ required "If `pgbouncer.clientSSL.certFile.existingSecret` is set, then `pgbouncer.clientSSL.keyFile.existingSecret` must also be!" nil }}
        {{- end }}
    {{- end }}
    {{- if .Values.pgbouncer.serverSSL.keyFile.existingSecret }}
        {{- if not .Values.pgbouncer.serverSSL.certFile.existingSecret }}
        {{ required "If `pgbouncer.serverSSL.keyFile.existingSecret` is set, then `pgbouncer.serverSSL.certFile.existingSecret` must also be!" nil }}
        {{- end }}
    {{- end }}
    {{- if .Values.pgbouncer.serverSSL.certFile.existingSecret }}
        {{- if not .Values.pgbouncer.serverSSL.keyFile.existingSecret }}
        {{ required "If `pgbouncer.serverSSL.certFile.existingSecret` is set, then `pgbouncer.serverSSL.keyFile.existingSecret` must also be!" nil }}
        {{- end }}
    {{- end }}
{{- end }}

{{/* Checks for `externalDatabase` */}}
{{- if .Values.externalDatabase.host }}
  {{/* check if they are using externalDatabase (the default value for `externalDatabase.host` is "localhost") */}}
  {{- if not (eq .Values.externalDatabase.host "localhost") }}
    {{- if .Values.postgresql.enabled }}
    {{ required "If `externalDatabase.host` is set, then `postgresql.enabled` should be `false`!" nil }}
    {{- end }}
    {{- if not (has .Values.externalDatabase.type (list "mysql" "postgres")) }}
    {{ required "The `externalDatabase.type` must be one of: [mysql, postgres]!" nil }}
    {{- end }}
  {{- end }}
{{- end }}

