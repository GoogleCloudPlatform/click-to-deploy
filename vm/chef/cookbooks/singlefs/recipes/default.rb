include_recipe 'c2d-config'

# Grafana dependencies and repositories on Debian 9

execute 'update1' do
  command 'apt-get update'
end

execute 'grafana_dependencies' do
  command 'apt-get -t stretch-backports install python-whisper'
end

execute 'add_grafana_repo' do
  command 'echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list'
end

execute 'install_repo_key' do
  command 'curl -s https://packages.grafana.com/gpg.key | apt-key add -'
end

# Install all packages

execute 'update2' do
  command 'apt-get update'
end

package 'install_packages' do
  package_name node['singlefs']['packages']
  action :install
end

# Scripts run on startup.

c2d_startup_script 'singlefs-install'
c2d_startup_script 'singlefs-monitoring'
c2d_startup_script 'singlefs-validate'

cookbook_file '/opt/c2d/apache2-graphite.conf' do
  source 'apache2-graphite.conf'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

cookbook_file '/opt/c2d/dashboard_storage.json' do
  source 'dashboard_storage.json'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

cookbook_file '/opt/c2d/dashboard_system.json' do
  source 'dashboard_system.json'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

cookbook_file '/opt/c2d/generate_dashboard_import.py' do
  source 'generate_dashboard_import.py'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/c2d/get_metadata.sh' do
  source 'get_metadata.sh'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/c2d/instance_utils.sh' do
  source 'instance_utils.sh'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/c2d/report_stats.py' do
  source 'report_stats.py'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/c2d/retry_with_backoff.sh' do
  source 'retry_with_backoff.sh'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/c2d/singlefs_util.py' do
  source 'singlefs_util.py'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

# Disable all services. They are enabled after c2d configuration.

service 'apache2' do
  action [ :disable, :stop ]
end

service 'collectd' do
  action [ :disable, :stop ]
end

service 'carbon-cache' do
  action [ :disable, :stop ]
end

service 'postgresql' do
  action [ :disable, :stop ]
end

service 'nfs-kernel-server' do
  action [ :disable, :stop ]
end

service 'nfs-common' do
  action [ :disable, :stop ]
end

service 'samba-ad-dc' do
  action [ :disable, :stop ]
end

service 'smbd' do
  action [ :disable, :stop ]
end
