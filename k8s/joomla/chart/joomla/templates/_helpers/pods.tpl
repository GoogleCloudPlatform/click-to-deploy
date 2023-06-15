{{- define "joomla.init_container.check_db" }}
- name: check-db
  image: busybox:1.35
  imagePullPolicy: IfNotPresent
  command:
    - sh
    - -c
    - |
      echo 'Waiting for MariaDB to become ready...'
      until printf "." && nc -z -w 2 "{{ .Release.Name }}-mariadb-svc" 3306; do
        sleep 2;
      done;
      echo 'MariaDB is ready'
{{- end }}

