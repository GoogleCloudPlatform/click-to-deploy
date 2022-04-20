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
- "/entrypoint"
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
    - "exec timeout 60s airflow db check"
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
    - "bash"
    - "-c"
    - "exec airflow db check-migrations -t 60"
  {{- if .volumeMounts }}
  volumeMounts:
    {{- .volumeMounts | indent 4 }}
  {{- end }}
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
The list of `volumeMounts` for web/scheduler/worker container
EXAMPLE USAGE: {{ include "airflow.volumeMounts" (dict "Release" .Release "Values" .Values "extraPipPackages" $extraPipPackages "extraVolumeMounts" $extraVolumeMounts) }}
*/}}
{{- define "airflow.volumeMounts" }}
{{- /* airflow_local_settings.py */ -}}
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
The list of `volumes` for web/scheduler/worker Pods
EXAMPLE USAGE: {{ include "airflow.volumes" (dict "Release" .Release "Values" .Values "extraPipPackages" $extraPipPackages "extraVolumes" $extraVolumes) }}
*/}}
{{- define "airflow.volumes" }}
{{- /* dags */ -}}
{{- if .Values.dags.persistence.enabled }}
- name: dags-data
  persistentVolumeClaim:
    {{- if .Values.dags.persistence.existingClaim }}
    claimName: {{ .Values.dags.persistence.existingClaim }}
    {{- else }}
    claimName: {{ printf "%s-dags" (.Release.Name | trunc 58) }}
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
    claimName: {{ printf "%s-logs" (.Release.Name | trunc 58) }}
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
    secretName: {{ .Release.Name }}-known-hosts
    defaultMode: 0644
{{- end }}
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
The list of `envFrom` for web/scheduler/worker Pods
*/}}
{{- define "airflow.envFrom" }}
- secretRef:
    name: {{ .Release.Name }}-config-envs
{{- end }}

{{/*
The list of `env` for web/scheduler/worker Pods
EXAMPLE USAGE: {{ include "airflow.env" (dict "Release" .Release "Values" .Values "CONNECTION_CHECK_MAX_COUNT" "0") }}
*/}}
{{- define "airflow.env" }}
- name: DATABASE_HOST
  value: {{ .Release.Name }}-postgresql-svc
{{- /* disable the `/entrypoint` db connection check */ -}}
- name: CONNECTION_CHECK_MAX_COUNT
  {{- if .CONNECTION_CHECK_MAX_COUNT }}
  value: {{ .CONNECTION_CHECK_MAX_COUNT | quote }}
  {{- else }}
  value: "0"
  {{- end }}
{{- end }}
