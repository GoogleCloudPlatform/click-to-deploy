# Do NOT include ZFS packages in this list. They can not be distributed by
# Google, so they are downloaded during installation if needed.
default['singlefs']['packages'] = ['apt-transport-https', 'nfs-kernel-server', 'samba', 'graphite-web', 'graphite-carbon', 'postgresql', 'libpq-dev', 'python-psycopg2', 'collectd', 'collectd-utils', 'apache2', 'libapache2-mod-wsgi', 'grafana', 'iptables-persistent', 'xfsprogs', 'mdadm']
