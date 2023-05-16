{{- define "wordpress.init_container.check_db" }}
- name: check-db
  image: busybox:1.35
  imagePullPolicy: IfNotPresent
  command:
    - sh
    - -c
    - |
      echo 'Waiting for MySQL to become ready...'
      until printf "." && nc -z -w 2 "{{ .Release.Name }}-mysql-svc" 3306; do
        sleep 2;
      done;
      echo 'MySQL is ready'
{{- end }}

