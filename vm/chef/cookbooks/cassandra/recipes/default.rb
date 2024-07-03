# Copyright 2022 Google LLC
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

include_recipe 'openjdk11'
include_recipe 'cassandra::ospo'

apt_repository 'cassandra_repository' do
  uri node['cassandra']['repo']['uri']
  components node['cassandra']['repo']['components']
  keyserver node['cassandra']['repo']['keyserver']
  distribution node['cassandra']['repo']['distribution']
  trusted true
end

apt_preference 'cassandra' do
  pin          "version #{node['cassandra']['apt_version']}"
  pin_priority '1000'
end

package 'cassandra' do
  :install
end

bash 'prepare_config_yaml_file' do
  code <<-EOH
    readonly conf_orig_file=/etc/cassandra/cassandra.yaml
    readonly conf_template_file=/etc/cassandra/cassandra.yaml.template

    cp "${conf_orig_file}" "${conf_template_file}"

    sed -i "s/seeds: \\"127.0.0.1:7000\\"/seeds: \\"\\${cassandra_seeds}\\"/" "${conf_template_file}"
    sed -i "s/^listen_address: localhost\\$/listen_address: \\${cassandra_internal_ip}/" "${conf_template_file}"
    sed -i "s/^rpc_address: localhost\\$/rpc_address: 0.0.0.0/" "${conf_template_file}"
    sed -i "s/^# broadcast_rpc_address: .*\\$/broadcast_rpc_address: \\${cassandra_internal_ip}/" "${conf_template_file}"
    sed -i "s/^cluster_name: .*\\$/cluster_name: '\\${cassandra_cluster_name}'/" "${conf_template_file}"
    sed -i "s/^max_hints_delivery_threads: .*\\$/max_hints_delivery_threads: 8/" "${conf_template_file}"
    sed -i "s/^concurrent_writes: .*\\$/concurrent_writes: \\${cassandra_concurrent_writes}/" "${conf_template_file}"
    sed -i "s/^# commitlog_total_space_in_mb: .*\\$/commitlog_total_space_in_mb: 2048/" "${conf_template_file}"
    sed -i "s/^#memtable_flush_writers: .*\\$/memtable_flush_writers: 2/" "${conf_template_file}"
    sed -i "s/^rpc_server_type: sync\\$/rpc_server_type: hsha/" "${conf_template_file}"
    sed -i "s/^# rpc_min_threads: .*\\$/rpc_min_threads: 16/" "${conf_template_file}"
    sed -i "s/^# rpc_max_threads: .*\\$/rpc_max_threads: 2048/" "${conf_template_file}"
    sed -i "s/^#concurrent_compactors: .*\\$/concurrent_compactors: 4/" "${conf_template_file}"
    sed -i "s/^compaction_throughput_mb_per_sec: .*\\$/compaction_throughput_mb_per_sec: 0/" "${conf_template_file}"
    sed -i "s/^endpoint_snitch: SimpleSnitch\\$/endpoint_snitch: GoogleCloudSnitch/" "${conf_template_file}"
EOH
end

bash 'prepare_env_config_script' do
  code <<-EOH
    readonly env_orig_file=/etc/cassandra/cassandra-env.sh
    readonly env_template_file=/etc/cassandra/cassandra-env.sh.template

    cp "${env_orig_file}" "${env_template_file}"

    sed -i "s|# set jvm HeapDumpPath with CASSANDRA_HEAPDUMP_DIR|# set jvm HeapDumpPath with CASSANDRA_HEAPDUMP_DIR\nCASSANDRA_HEAPDUMP_DIR=\\${cassandra_mount_dir}/dumps|" "${env_template_file}"

    # Make sure that the file ends with new line.
    echo -e "\n" >> "${env_template_file}"

    # Additional JVM options to be appended to file.
    echo "JVM_OPTS=\\"\\$JVM_OPTS -XX:TargetSurvivorRatio=50\\"" >> "${env_template_file}"
    echo "JVM_OPTS=\\"\\$JVM_OPTS -XX:MaxDirectMemorySize=5g\\"" >> "${env_template_file}"
    echo "JVM_OPTS=\\"\\$JVM_OPTS -XX:+UseLargePages\\"" >> "${env_template_file}"
EOH
end

# Set Java 11
package 'java-common' do
  :install
end

bash 'Set Java 11' do
  code <<-EOH
  update-java-alternatives -s java-1.11.0-openjdk-amd64
EOH
end

c2d_startup_script 'cassandra'
