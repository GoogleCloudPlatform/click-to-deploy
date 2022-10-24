{{- define "conjur.init_container.check_db" }}
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

