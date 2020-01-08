  CREATE USER IF NOT EXISTS '{{ .Values.db.exporter.username }}'@'127.0.0.1' IDENTIFIED BY '{{ .Values.db.exporter.password }}' WITH MAX_USER_CONNECTIONS 3;
  # https://dev.mysql.com/doc/refman/5.6/en/grant.html
  GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '{{ .Values.db.exporter.username }}'@'127.0.0.1';
  FLUSH PRIVILEGES;
