{{- define "dragonfly.init_container.check_db" }}
- name: wait-for-redis
  image: busybox
  imagePullPolicy: IfNotPresent
  command: ['sh', '-c', 'until nc -vz {{ .Release.Name }}-redis-svc 6379; do echo waiting for redis; sleep 2; done;']
- name: wait-for-mysql
  image: busybox
  imagePullPolicy: IfNotPresent
  command: ['sh', '-c', 'until nc -vz {{ .Release.Name }}-mysql-svc 3306; do echo waiting for mysql; sleep 2; done;']
{{- end }}

{{- define "dragonfly.init_container.wait_for_manager" }}
- name: wait-for-manager
  image: busybox
  imagePullPolicy: IfNotPresent
  command: ['sh', '-c', 'until nc -vz {{ .Release.Name }}-manager-service {{ .Values.manager.restPort }}; do echo waiting for manager; sleep 2; done;']
{{- end }}

{{- define "dragonfly.init_container.wait_for_scheduler" }}
- name: wait-for-scheduler
  image: busybox
  imagePullPolicy: IfNotPresent
  command: ['sh', '-c', 'until nc -vz {{ .Release.Name }}-scheduler-service {{ .Values.scheduler.grpcPort }}; do echo waiting for scheduler; sleep 2; done;']
{{- end }}

{{- define "dragonfly.init_container.update_containerd" }}
- name: update-containerd
  image: dragonflyoss/openssl
  imagePullPolicy: IfNotPresent         
  command:
  - /bin/sh
  - -cx
  - |-
    etcContainerd=/host/etc/containerd 
    if [[ -e $etcContainerd/config.toml ]]; then
      echo containerd config found
    else
      echo $etcContainerd/config.toml not found
      exit 1
    fi

    registries="https://ghcr.io https://quay.io https://harbor.example.com:8443"
    if [[ -n "$domains" ]]; then
      echo empty registry domains
      exit 1
    fi
    # detect containerd config version
    need_restart=0
    if grep "version[^=]*=[^2]*2" $etcContainerd/config.toml; then
      # inject v2 mirror setting
    
      # get config_path if set

      config_path=$(cat $etcContainerd/config.toml | tr '"' ' ' | grep config_path | awk '{print $3}')
    
      if [[ -z "$config_path" ]]; then
        echo config_path is not enabled, just add one mirror in config.toml
        # parse registry domain
        registry=https://index.docker.io
        domain=$(echo $registry | sed -e "s,https://,," | sed "s,:.*,,")
        # inject registry
        if grep "registry.mirrors.\"$domain\"" $etcContainerd/config.toml; then
          # TODO merge mirrors
          echo "registry $registry found in config.toml, skip"
        
      fi  
      else
        echo config_path is enabled, add mirror in $config_path
        # TODO check whether config_path is enabled, if not, add it
        tmp=$(cat $etcContainerd/config.toml | tr '"' ' ' | grep config_path | awk '{print $3}')
        if [[ -z "$tmp" ]]; then
          echo inject config_path into $etcContainerd/config.toml
          cat << EOF >> $etcContainerd/config.toml
          [plugins."io.containerd.grpc.v1.cri".registry]
          config_path = "/etc/containerd/certs.d"
    EOF
        fi
        mkdir -p $etcContainerd/certs.d
        for registry in $registries; do
          # parse registry domain
          domain=$(echo $registry | sed -e "s,http.://,," | sed "s,:.*,,")
          # inject registry
          mkdir -p $etcContainerd/certs.d/$domain
          if [[ -e "$etcContainerd/certs.d/$domain/hosts.toml" ]]; then
            echo "registry $registry found in config.toml, skip"
            continue
          else
            cat << EOF >> $etcContainerd/certs.d/$domain/hosts.toml
            server = "$registry"
            [host."http://127.0.0.1:65001"]
            capabilities = ["pull", "resolve"]
            [host."http://127.0.0.1:65001".header]
            X-Dragonfly-Registry = ["$registry"]
    EOF
            echo "Registry $domain added"
          
            need_restart=1
          
          fi
        done
      fi
    else
      # inject legacy v1 mirror setting
      echo containerd config is version 1, just only support one mirror in config.toml
      # parse registry domain
      registry=https://index.docker.io
      domain=$(echo https://index.docker.io | sed -e "s,http.://,," | sed "s,:.*,,")
      # inject registry
      if grep "registry.mirrors.\"$domain\"" $etcContainerd/config.toml; then
        # TODO merge mirrors
        echo "registry $registry found in config.toml, skip"
      else
        cat << EOF >> $etcContainerd/config.toml
        [plugins.cri.registry.mirrors."$domain"]
        endpoint = ["http://127.0.0.1:65001","$registry"]
    EOF
        echo "Registry $domain added"
        need_restart=1
      fi
    fi
    # restart containerd
    # currently, without host pid in container, we can not nsenter with pid and can not invoke systemctl correctly.
    if [[ "$need_restart" -gt 0 ]]; then
      nsenter -t 1 -m systemctl -- restart containerd.service
    fi
  volumeMounts:
    - name: containerd-conf
      mountPath: /host/etc/containerd 
  securityContext:          
    privileged: true
{{- end }}

