{{/*
Define the image configs for airflow containers
*/}}
{{- define "airflow.image" }}
image: {{ .Values.airflow.image.repository }}:{{ .Values.airflow.image.tag }}
imagePullPolicy: {{ .Values.airflow.image.pullPolicy }}
securityContext:
  runAsUser: {{ .Values.airflow.image.uid }}
  runAsGroup: {{ .Values.airflow.image.gid }}
{{- end }}

{{/*
Define the command/entrypoint configs for airflow containers
*/}}
{{- define "airflow.command" }}
- "/usr/bin/dumb-init"
- "--"
{{- /* only use `/entrypoint` for airflow 2.0+ (older images dont pass "bash" & "python") */ -}}
{{- if not .Values.airflow.legacyCommands }}
- "/entrypoint"
{{- end }}
{{- end }}

{{/*
Define the nodeSelector for airflow pods
EXAMPLE USAGE: {{ include "airflow.nodeSelector" (dict "Release" .Release "Values" .Values "nodeSelector" $nodeSelector) }}
*/}}
{{- define "airflow.podNodeSelector" }}
{{- .nodeSelector | default .Values.airflow.defaultNodeSelector | toYaml }}
{{- end }}

{{/*
Define the Affinity for airflow pods
EXAMPLE USAGE: {{ include "airflow.podAffinity" (dict "Release" .Release "Values" .Values "affinity" $affinity) }}
*/}}
{{- define "airflow.podAffinity" }}
{{- .affinity | default .Values.airflow.defaultAffinity | toYaml }}
{{- end }}

{{/*
Define the Tolerations for airflow pods
EXAMPLE USAGE: {{ include "airflow.podTolerations" (dict "Release" .Release "Values" .Values "tolerations" $tolerations) }}
*/}}
{{- define "airflow.podTolerations" }}
{{- .tolerations | default .Values.airflow.defaultTolerations | toYaml }}
{{- end }}

{{/*
Define the PodSecurityContext for airflow pods
EXAMPLE USAGE: {{ include "airflow.podSecurityContext" (dict "Release" .Release "Values" .Values "securityContext" $securityContext) }}
*/}}
{{- define "airflow.podSecurityContext" }}
{{- .securityContext | default .Values.airflow.defaultSecurityContext | toYaml }}
{{- end }}

{{/*
Define an init-container which checks the DB status
EXAMPLE USAGE: {{ include "airflow.init_container.check_db" (dict "Release" .Release "Values" .Values "volumeMounts" $volumeMounts) }}
*/}}
{{- define "airflow.init_container.check_db" }}
- name: check-db
  {{- include "airflow.image" . | indent 2 }}
  envFrom:
    {{- include "airflow.envFrom" . | indent 4 }}
  env:
    {{- include "airflow.env" . | indent 4 }}
  command:
    {{- include "airflow.command" . | indent 4 }}
  args:
    - "bash"
    - "-c"
    {{- if .Values.airflow.legacyCommands }}
    - "exec timeout 60s airflow checkdb"
    {{- else }}
    - "exec timeout 60s airflow db check"
    {{- end }}
  {{- if .volumeMounts }}
  volumeMounts:
    {{- .volumeMounts | indent 4 }}
  {{- end }}
{{- end }}

{{/*
Define an init-container which waits for DB migrations
EXAMPLE USAGE: {{ include "airflow.init_container.wait_for_db_migrations" (dict "Release" .Release "Values" .Values "volumeMounts" $volumeMounts) }}
*/}}
{{- define "airflow.init_container.wait_for_db_migrations" }}
- name: wait-for-db-migrations
  {{- include "airflow.image" . | indent 2 }}
  envFrom:
    {{- include "airflow.envFrom" . | indent 4 }}
  env:
    {{- include "airflow.env" . | indent 4 }}
  command:
    {{- include "airflow.command" . | indent 4 }}
  args:
    {{- if .Values.airflow.legacyCommands }}
    - "python"
    - "-c"
    - |
      import logging
      import os
      import time

      import airflow
      from airflow import settings

      # modified from https://github.com/apache/airflow/blob/2.1.0/airflow/utils/db.py#L583-L592
      def _get_alembic_config():
          from alembic.config import Config

          package_dir = os.path.abspath(os.path.dirname(airflow.__file__))
          directory = os.path.join(package_dir, 'migrations')
          config = Config(os.path.join(package_dir, 'alembic.ini'))
          config.set_main_option('script_location', directory.replace('%', '%%'))
          config.set_main_option('sqlalchemy.url', settings.SQL_ALCHEMY_CONN.replace('%', '%%'))
          return config

      # copied from https://github.com/apache/airflow/blob/2.1.0/airflow/utils/db.py#L595-L622
      def check_migrations(timeout):
          """
          Function to wait for all airflow migrations to complete.
          :param timeout: Timeout for the migration in seconds
          :return: None
          """
          from alembic.runtime.migration import MigrationContext
          from alembic.script import ScriptDirectory

          config = _get_alembic_config()
          script_ = ScriptDirectory.from_config(config)
          with settings.engine.connect() as connection:
              context = MigrationContext.configure(connection)
              ticker = 0
              while True:
                  source_heads = set(script_.get_heads())
                  db_heads = set(context.get_current_heads())
                  if source_heads == db_heads:
                      break
                  if ticker >= timeout:
                      raise TimeoutError(
                          f"There are still unapplied migrations after {ticker} seconds. "
                          f"Migration Head(s) in DB: {db_heads} | Migration Head(s) in Source Code: {source_heads}"
                      )
                  ticker += 1
                  time.sleep(1)
                  logging.info('Waiting for migrations... %s second(s)', ticker)

      check_migrations(60)
    {{- else }}
    - "bash"
    - "-c"
    - "exec airflow db check-migrations -t 60"
    {{- end }}
  {{- if .volumeMounts }}
  volumeMounts:
    {{- .volumeMounts | indent 4 }}
  {{- end }}
{{- end }}

{{/*
Define an init-container which installs a list of pip packages
EXAMPLE USAGE: {{ include "airflow.init_container.install_pip_packages" (dict "Release" .Release "Values" .Values "extraPipPackages" $extraPipPackages) }}
*/}}
{{- define "airflow.init_container.install_pip_packages" }}
- name: install-pip-packages
  {{- include "airflow.image" . | indent 2 }}
  envFrom:
    {{- include "airflow.envFrom" . | indent 4 }}
  env:
    {{- include "airflow.env" . | indent 4 }}
  command:
    {{- include "airflow.command" . | indent 4 }}
  args:
    - "bash"
    - "-c"
    - |
      unset PYTHONUSERBASE && \
      pip install --user {{ range .extraPipPackages }}{{ . | quote }} {{ end }} && \
      echo "copying '/home/airflow/.local/*' to '/opt/home-airflow-local'..." && \
      cp -r /home/airflow/.local/* /opt/home-airflow-local
  volumeMounts:
    - name: home-airflow-local
      mountPath: /opt/home-airflow-local
{{- end }}

{{/*
Define a container which regularly syncs a git-repo
EXAMPLE USAGE: {{ include "airflow.container.git_sync" (dict "Release" .Release "Values" .Values "sync_one_time" "true") }}
*/}}
{{- define "airflow.container.git_sync" }}
{{- if .sync_one_time }}
- name: dags-git-clone
{{- else }}
- name: dags-git-sync
{{- end }}
  image: {{ .Values.dags.gitSync.image.repository }}:{{ .Values.dags.gitSync.image.tag }}
  imagePullPolicy: {{ .Values.dags.gitSync.image.pullPolicy }}
  securityContext:
    runAsUser: {{ .Values.dags.gitSync.image.uid }}
    runAsGroup: {{ .Values.dags.gitSync.image.gid }}
  resources:
    {{- toYaml .Values.dags.gitSync.resources | nindent 4 }}
  envFrom:
    {{- include "airflow.envFrom" . | indent 4 }}
  env:
    {{- if .sync_one_time }}
    - name: GIT_SYNC_ONE_TIME
      value: "true"
    {{- end }}
    - name: GIT_SYNC_ROOT
      value: "/dags"
    - name: GIT_SYNC_DEST
      value: "repo"
    - name: GIT_SYNC_REPO
      value: {{ .Values.dags.gitSync.repo | quote }}
    - name: GIT_SYNC_BRANCH
      value: {{ .Values.dags.gitSync.branch | quote }}
    - name: GIT_SYNC_REV
      value: {{ .Values.dags.gitSync.revision | quote }}
    - name: GIT_SYNC_DEPTH
      value: {{ .Values.dags.gitSync.depth | quote }}
    - name: GIT_SYNC_WAIT
      value: {{ .Values.dags.gitSync.syncWait | quote }}
    - name: GIT_SYNC_TIMEOUT
      value: {{ .Values.dags.gitSync.syncTimeout | quote }}
    - name: GIT_SYNC_ADD_USER
      value: "true"
    - name: GIT_SYNC_MAX_SYNC_FAILURES
      value: {{ .Values.dags.gitSync.maxFailures | quote }}
    {{- if .Values.dags.gitSync.sshSecret }}
    - name: GIT_SYNC_SSH
      value: "true"
    - name: GIT_SSH_KEY_FILE
      value: "/etc/git-secret/id_rsa"
    {{- end }}
    {{- if .Values.dags.gitSync.sshKnownHosts }}
    - name: GIT_KNOWN_HOSTS
      value: "true"
    - name: GIT_SSH_KNOWN_HOSTS_FILE
      value: "/etc/git-secret/known_hosts"
    {{- else }}
    - name: GIT_KNOWN_HOSTS
      value: "false"
    {{- end }}
    {{- if .Values.dags.gitSync.httpSecret }}
    - name: GIT_SYNC_USERNAME
      valueFrom:
        secretKeyRef:
          name: {{ .Values.dags.gitSync.httpSecret }}
          key: {{ .Values.dags.gitSync.httpSecretUsernameKey }}
    - name: GIT_SYNC_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ .Values.dags.gitSync.httpSecret }}
          key: {{ .Values.dags.gitSync.httpSecretPasswordKey }}
    {{- end }}
    {{- /* this has user-defined variables, so must be included BELOW (so the ABOVE `env` take precedence) */ -}}
    {{- include "airflow.env" . | indent 4 }}
  volumeMounts:
    - name: dags-data
      mountPath: /dags
    {{- if .Values.dags.gitSync.sshSecret }}
    - name: git-secret
      mountPath: /etc/git-secret/id_rsa
      readOnly: true
      subPath: {{ .Values.dags.gitSync.sshSecretKey }}
    {{- end }}
    {{- if .Values.dags.gitSync.sshKnownHosts }}
    - name: git-known-hosts
      mountPath: /etc/git-secret/known_hosts
      readOnly: true
      subPath: known_hosts
    {{- end }}
{{- end }}

{{/*
Define a container which regularly deletes airflow logs older than a retention period.
EXAMPLE USAGE: {{ include "airflow.container.log_cleanup" (dict "Release" .Release "Values" .Values "resources" $lc_resources "retention_min" $lc_retention_min "interval_sec" $lc_interval_sec) }}
*/}}
{{- define "airflow.container.log_cleanup" }}
- name: log-cleanup
  {{- include "airflow.image" . | indent 2 }}
  resources:
    {{- toYaml .resources | nindent 4 }}
  envFrom:
    {{- include "airflow.envFrom" . | indent 4 }}
  env:
    - name: LOG_PATH
      value: {{ .Values.logs.path | quote }}
    - name: RETENTION_MINUTES
      value: {{ .retention_min | quote }}
    - name: INTERVAL_SECONDS
      value: {{ .interval_sec | quote }}
    {{- /* this has user-defined variables, so must be included BELOW (so the ABOVE `env` take precedence) */ -}}
    {{- include "airflow.env" . | indent 4 }}
  command:
    {{- include "airflow.command" . | indent 4 }}
  args:
    - "bash"
    - "-c"
    - |
      set -euo pipefail

      # break the infinite loop when we receive SIGINT or SIGTERM
      trap "exit 0" SIGINT SIGTERM

      while true; do
        START_EPOCH=$(date --utc +%s)
        echo "[$(date --utc +%FT%T.%3N)] deleting log files older than $RETENTION_MINUTES minutes..."

        # delete all writable files ending in ".log" with modified-time older than $RETENTION_MINUTES
        # NOTE: `-printf "."` prints a "." for each deleted file, which we count the bytes of with `wc -c`
        DELETED_COUNT=$(
          find "$LOG_PATH" \
            -type f \
            -name "*.log" \
            -mmin +"$RETENTION_MINUTES" \
            -writable \
            -delete \
            -printf "." \
          | wc -c
        )

        END_EPOCH=$(date --utc +%s)
        LOOP_DURATION=$((END_EPOCH - START_EPOCH))
        echo "[$(date --utc +%FT%T.%3N)] deleted $DELETED_COUNT files in $LOOP_DURATION seconds"

        SECONDS_TO_SLEEP=$((INTERVAL_SECONDS - LOOP_DURATION))
        if (( SECONDS_TO_SLEEP > 0 )); then
          echo "[$(date --utc +%FT%T.%3N)] waiting $SECONDS_TO_SLEEP seconds..."
          sleep $SECONDS_TO_SLEEP
        fi
      done
  volumeMounts:
    - name: logs-data
      mountPath: {{ .Values.logs.path }}
{{- end }}

{{/*
The list of `volumeMounts` for web/scheduler/worker/flower container
EXAMPLE USAGE: {{ include "airflow.volumeMounts" (dict "Release" .Release "Values" .Values "extraPipPackages" $extraPipPackages "extraVolumeMounts" $extraVolumeMounts) }}
*/}}
{{- define "airflow.volumeMounts" }}
{{- /* airflow_local_settings.py */ -}}
{{- if or (.Values.airflow.localSettings.stringOverride) (.Values.airflow.localSettings.existingSecret) }}
- name: airflow-local-settings
  mountPath: /opt/airflow/config/airflow_local_settings.py
  subPath: airflow_local_settings.py
  readOnly: true
{{- end }}

{{- /* dags */ -}}
{{- if .Values.dags.persistence.enabled }}
- name: dags-data
  mountPath: {{ .Values.dags.path }}
  subPath: {{ .Values.dags.persistence.subPath }}
  {{- if eq .Values.dags.persistence.accessMode "ReadOnlyMany" }}
  readOnly: true
  {{- end }}
{{- else if .Values.dags.gitSync.enabled }}
- name: dags-data
  mountPath: {{ .Values.dags.path }}
{{- end }}

{{- /* logs */ -}}
{{- if .Values.logs.persistence.enabled }}
- name: logs-data
  mountPath: {{ .Values.logs.path }}
  subPath: {{ .Values.logs.persistence.subPath }}
{{- else }}
- name: logs-data
  mountPath: {{ .Values.logs.path }}
{{- end }}

{{- /* pip-packages */ -}}
{{- if .extraPipPackages }}
- name: home-airflow-local
  mountPath: /home/airflow/.local
{{- end }}

{{- /* user-defined (global) */ -}}
{{- if .Values.airflow.extraVolumeMounts }}
{{ toYaml .Values.airflow.extraVolumeMounts }}
{{- end }}

{{- /* user-defined */ -}}
{{- if .extraVolumeMounts }}
{{ toYaml .extraVolumeMounts }}
{{- end }}
{{- end }}

{{/*
The list of `volumes` for web/scheduler/worker/flower Pods
EXAMPLE USAGE: {{ include "airflow.volumes" (dict "Release" .Release "Values" .Values "extraPipPackages" $extraPipPackages "extraVolumes" $extraVolumes) }}
*/}}
{{- define "airflow.volumes" }}
{{- /* airflow_local_settings.py */ -}}
{{- if or (.Values.airflow.localSettings.stringOverride) (.Values.airflow.localSettings.existingSecret) }}
- name: airflow-local-settings
  secret:
    {{- if .Values.airflow.localSettings.existingSecret }}
    secretName: {{ .Values.airflow.localSettings.existingSecret }}
    {{- else }}
    secretName: {{ include "airflow.fullname" . }}-local-settings
    {{- end }}
    defaultMode: 0644
{{- end }}

{{- /* dags */ -}}
{{- if .Values.dags.persistence.enabled }}
- name: dags-data
  persistentVolumeClaim:
    {{- if .Values.dags.persistence.existingClaim }}
    claimName: {{ .Values.dags.persistence.existingClaim }}
    {{- else }}
    claimName: {{ printf "%s-dags" (include "airflow.fullname" . | trunc 58) }}
    {{- end }}
{{- else if .Values.dags.gitSync.enabled }}
- name: dags-data
  emptyDir: {}
{{- end }}

{{- /* logs */ -}}
{{- if .Values.logs.persistence.enabled }}
- name: logs-data
  persistentVolumeClaim:
    {{- if .Values.logs.persistence.existingClaim }}
    claimName: {{ .Values.logs.persistence.existingClaim }}
    {{- else }}
    claimName: {{ printf "%s-logs" (include "airflow.fullname" . | trunc 58) }}
    {{- end }}
{{- else }}
- name: logs-data
  emptyDir: {}
{{- end }}

{{- /* git-sync */ -}}
{{- if .Values.dags.gitSync.enabled }}
{{- if .Values.dags.gitSync.sshSecret }}
- name: git-secret
  secret:
    secretName: {{ .Values.dags.gitSync.sshSecret }}
    defaultMode: 0644
{{- end }}
{{- if .Values.dags.gitSync.sshKnownHosts }}
- name: git-known-hosts
  secret:
    secretName: {{ include "airflow.fullname" . }}-known-hosts
    defaultMode: 0644
{{- end }}
{{- end }}

{{- /* pip-packages */ -}}
{{- if .extraPipPackages }}
- name: home-airflow-local
  emptyDir: {}
{{- end }}

{{- /* user-defined (global) */ -}}
{{- if .Values.airflow.extraVolumes }}
{{ toYaml .Values.airflow.extraVolumes }}
{{- end }}

{{- /* user-defined */ -}}
{{- if .extraVolumes }}
{{ toYaml .extraVolumes }}
{{- end }}
{{- end }}

{{/*
The list of `envFrom` for web/scheduler/worker/flower Pods
*/}}
{{- define "airflow.envFrom" }}
- secretRef:
    name: {{ include "airflow.fullname" . }}-config-envs
{{- end }}

{{/*
The list of `env` for web/scheduler/worker/flower Pods
EXAMPLE USAGE: {{ include "airflow.env" (dict "Release" .Release "Values" .Values "CONNECTION_CHECK_MAX_COUNT" "0") }}
*/}}
{{- define "airflow.env" }}
{{- /* set DATABASE_USER */ -}}
{{- if .Values.postgresql.enabled }}
- name: DATABASE_USER
  value: {{ .Values.postgresql.postgresqlUsername | quote }}
{{- else }}
{{- if .Values.externalDatabase.userSecret }}
- name: DATABASE_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.userSecret }}
      key: {{ .Values.externalDatabase.userSecretKey }}
{{- else }}
{{- /* in this case, DATABASE_USER is set in the `-config-envs` Secret */ -}}
{{- end }}
{{- end }}

{{- /* set DATABASE_PASSWORD */ -}}
{{- if .Values.postgresql.enabled }}
{{- if .Values.postgresql.existingSecret }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgresql.existingSecret }}
      key: {{ .Values.postgresql.existingSecretKey }}
{{- else }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "airflow.postgresql.fullname" . }}
      key: postgresql-password
{{- end }}
{{- else }}
{{- if .Values.externalDatabase.passwordSecret }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalDatabase.passwordSecret }}
      key: {{ .Values.externalDatabase.passwordSecretKey }}
{{- else }}
{{- /* in this case, DATABASE_PASSWORD is set in the `-config-envs` Secret */ -}}
{{- end }}
{{- end }}

{{- /* set REDIS_PASSWORD */ -}}
{{- if .Values.redis.enabled }}
{{- if .Values.redis.existingSecret }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.redis.existingSecret }}
      key: {{ .Values.redis.existingSecretPasswordKey }}
{{- else }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "airflow.redis.fullname" . }}
      key: redis-password
{{- end }}
{{- else }}
{{- if .Values.externalRedis.passwordSecret }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.externalRedis.passwordSecret }}
      key: {{ .Values.externalRedis.passwordSecretKey }}
{{- else }}
{{- /* in this case, REDIS_PASSWORD is set in the `-config-envs` Secret */ -}}
{{- end }}
{{- end }}

{{- /* disable the `/entrypoint` db connection check */ -}}
{{- if not .Values.airflow.legacyCommands }}
- name: CONNECTION_CHECK_MAX_COUNT
  {{- if .CONNECTION_CHECK_MAX_COUNT }}
  value: {{ .CONNECTION_CHECK_MAX_COUNT | quote }}
  {{- else }}
  value: "0"
  {{- end }}
{{- end }}

{{- /* set AIRFLOW__CELERY__FLOWER_BASIC_AUTH */ -}}
{{- if .Values.flower.basicAuthSecret }}
- name: AIRFLOW__CELERY__FLOWER_BASIC_AUTH
  valueFrom:
    secretKeyRef:
      name: {{ .Values.flower.basicAuthSecret }}
      key: {{ .Values.flower.basicAuthSecretKey }}
{{- end }}

{{- /* user-defined environment variables */ -}}
{{- if .Values.airflow.extraEnv }}
{{ toYaml .Values.airflow.extraEnv }}
{{- end }}
{{- end }}
