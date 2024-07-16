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

include_recipe 'python'
include_recipe 'redis::standalone'
include_recipe 'erpnext::ospo'

apt_update do
  action :update
end

node['erpnext']['mariadb']['packages'].each do |pkg|
  apt_preference pkg do
    pin          "version #{node['erpnext']['mariadb']['apt_version']}"
    pin_priority '1000'
  end
end

package 'Install packages' do
  package_name node['erpnext']['mariadb']['packages']
  action :install
end

package 'Install packages' do
  package_name node['erpnext']['packages']
  action :install
end

# Create frappe user.
user node['erpnext']['frappe']['user'] do
  action :create
  home "/home/#{node['erpnext']['frappe']['user']}"
  shell '/bin/bash'
  password node['erpnext']['frappe']['password']
  manage_home true
end

# Add frappe user to sudo.
template "/etc/sudoers.d/#{node['erpnext']['frappe']['user']}" do
  source 'etc-sudoers.d-frappeuser.erb'
  owner  'root'
  group  'root'
  mode   '0440'
  verify 'visudo -c -f %{path}'
  variables(frappeuser: node['erpnext']['frappe']['user'])
end

bash 'Set MariaDB root password' do
  code <<-EOH
    mysqladmin -uroot password "#{node['erpnext']['mysql-root-password']}"

    mysql -uroot -p"#{node['erpnext']['mysql-root-password']}" <<EOSQL
      DELETE FROM mysql.user WHERE User='';
      DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
      FLUSH PRIVILEGES;
EOSQL
  EOH
end

# Add required MariaDB configuration
cookbook_file '/etc/mysql/mariadb.conf.d/70-frappe.cnf' do
  source 'frappe.cnf'
  owner 'root'
  group 'root'
  mode 0664
  action :create
end

service 'mysql' do
  action :restart
end

# Install NodeJS
remote_file "/home/#{node['erpnext']['frappe']['user']}/setup_nodejs" do
  source "https://deb.nodesource.com/setup_#{node['erpnext']['nodejs']['version']}.x"
  action :create
end

bash 'Setup nodejs' do
  code <<-EOH
    bash /home/#{node['erpnext']['frappe']['user']}/setup_nodejs
  EOH
end

package 'Install nodejs' do
  package_name 'nodejs'
  action :install
end

bash 'Install yarn' do
  code <<-EOH
    npm install -g yarn
  EOH
end

bash 'Install bench' do
  code <<-EOH
    pip3 install frappe-bench
  EOH
end

bash 'Init bench' do
  code <<-EOH
    su - #{node['erpnext']['frappe']['user']} -c \
      "bench init \
        --frappe-branch version-#{node['erpnext']['version']} \
        --python /usr/local/bin/python3.10 \
        #{node['erpnext']['frappe']['bench']}"
  EOH
end

bash 'Create bench site' do
  user node['erpnext']['frappe']['user']
  cwd "/home/#{node['erpnext']['frappe']['user']}/#{node['erpnext']['frappe']['bench']}"
  code <<-EOH
    bench new-site \
      --mariadb-root-password="#{node['erpnext']['mysql-root-password']}" \
      --admin-password="#{node['erpnext']['erpnext-admin-password']}" \
      #{node['erpnext']['site']}
  EOH
end

bash 'Install erpnext app' do
  user node['erpnext']['frappe']['user']
  cwd "/home/#{node['erpnext']['frappe']['user']}/#{node['erpnext']['frappe']['bench']}"
  code <<-EOH
    bench get-app --branch version-#{node['erpnext']['version']} erpnext
    bench --site #{node['erpnext']['site']} install-app erpnext
    bench --site #{node['erpnext']['site']} enable-scheduler
  EOH
end

bash 'Setup production' do
  user node['erpnext']['frappe']['user']
  cwd "/home/#{node['erpnext']['frappe']['user']}/#{node['erpnext']['frappe']['bench']}"
  code <<-EOH
    sudo bench setup production #{node['erpnext']['frappe']['user']} --yes
  EOH
end

link '/etc/supervisor/conf.d/frappe-bench.conf' do
  to "/home/#{node['erpnext']['frappe']['user']}/#{node['erpnext']['frappe']['bench']}/config/supervisor.conf"
end

bash 'Setup supervisor' do
  user node['erpnext']['frappe']['user']
  cwd "/home/#{node['erpnext']['frappe']['user']}/#{node['erpnext']['frappe']['bench']}"
  code <<-EOH
    sudo supervisorctl update
    sudo supervisorctl restart all
  EOH
end

# Save initial root password. Will be changed during startup.
file '/mysql_initial_password' do
  content node['erpnext']['mysql-root-password']
end

# Cleanup sudoers file.
file "/etc/sudoers.d/#{node['erpnext']['frappe']['user']}" do
  action :delete
end

# Cleanup nodejs setup script.
file "/home/#{node['erpnext']['frappe']['user']}/setup_nodejs" do
  action :delete
end

c2d_startup_script 'erpnext-setup'
