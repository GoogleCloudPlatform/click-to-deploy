{{- define "argoworkflows.wait_for_db" }}
- name: check-db
  image: marketplace.gcr.io/google/c2d-debian11
  imagePullPolicy: IfNotPresent
  command:
    - sh
    - -c
    - |
      apt update && apt -y install netcat
      echo 'Waiting for PostgreSQL to become ready...'
      until printf "." && nc -z -w 2 "{{- include "argoworkflows.db_svc" . }}" 5432; do
        sleep 2;
      done;
      echo 'PostgreSQL is ready'
{{- end }}
