# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'percona::ospo'

bash 'Download Percona repo package' do
  code <<-EOH
    apt-get install wget -y
    wget -P /tmp/ https://repo.percona.com/percona/apt/percona-release_#{node['percona']['version']}.#{node['percona']['debian']['codename']}_all.deb
EOH
end

bash 'Install Percona repo package' do
  code <<-EOH
    dpkg -i /tmp/percona-release_#{node['percona']['version']}.#{node['percona']['debian']['codename']}_all.deb
EOH
end

apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

bash 'Download percona-toolkit package and dependencies' do
  code <<-EOH
    mkdir -p /opt/c2d/downloads/percona-toolkit
    apt-get -d -o Dir::Cache::archives="/opt/c2d/downloads/percona-toolkit" install percona-toolkit -y
EOH
end

bash 'Install Percona packages' do
  code <<-EOH
    DEBIAN_FRONTEND=noninteractive apt-get install -y #{node['percona']['pkg']}
EOH
end

bash 'Set required mysqld options for Percona XtraDB Cluster' do
  code <<-EOH
    cat > /etc/mysql/percona-xtradb-cluster.conf.d/mysqld.cnf << 'EOF'
    #
    # Required mysqld options for Percona XtraDB Cluster
    [mysqld]
    binlog_format=ROW
    innodb_autoinc_lock_mode=2
    innodb_flush_method=O_DIRECT
    innodb_flush_log_at_trx_commit=2
    datadir=/var/lib/mysql
    socket=/var/run/mysqld/mysqld.sock
    log-error=/var/log/mysqld.log
    pid-file=/var/run/mysqld/mysqld.pid
EOF
EOH
end

bash 'Set required mysqld options for Percona XtraDB Cluster with Galera' do
  code <<-EOH
    cat > /etc/mysql/percona-xtradb-cluster.conf.d/wsrep.cnf << 'EOF'
    # Required mysqld options for Percona XtraDB Cluster with Galera
    # http://www.percona.com/doc/percona-xtradb-cluster/5.7/wsrep-system-index.html
    #
    [mysqld]
    wsrep_provider=/usr/lib/galera3/libgalera_smm.so
    wsrep_provider_options="gcache.size=2G; gcs.fc_limit=128"
    wsrep_sst_method=xtrabackup-v2
    wsrep_slave_threads=4
EOF
EOH
end

bash 'Create userdefined functions' do
  code <<-EOH
    mysql << EOF
    CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so';
    CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so';
    CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so';
EOF
EOH
end

bash 'Create replication user account' do
  code <<-EOH
    mysql << EOF
    CREATE USER 'sstuser'@'localhost' IDENTIFIED BY 'sstuser';
    GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'sstuser'@'localhost';
    FLUSH PRIVILEGES;
EOF
EOH
end

service 'mysql' do
  action :stop
end

c2d_startup_script 'percona-setup'
