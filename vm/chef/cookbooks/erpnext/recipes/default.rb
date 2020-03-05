# Copyright 2020 Google LLC
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

# Download installation script.
remote_file "/home/#{node['erpnext']['frappe']['user']}/install.py" do
  source node['erpnext']['install-script']
  action :create
end

bash 'Install ERPNext' do
  user node['erpnext']['frappe']['user']
  code <<-EOH
    sudo -n python3 /home/#{node['erpnext']['frappe']['user']}/install.py --production \
         --site #{node['erpnext']['site']} \
         --user #{node['erpnext']['frappe']['user']} \
         --mysql-root-password #{node['erpnext']['mysql-root-password']} \
         --admin-password #{node['erpnext']['erpnext-admin-password']} \
         --bench-name #{node['erpnext']['frappe']['bench']} \
         --version #{node['erpnext']['version']}
EOH
  flags '-eu'
  environment({
    'PYTHONIOENCODING' => 'utf-8',
    'LANGUAGE' => 'en_US.UTF-8',
    'LANG' => 'en_US.UTF-8',
    'LC_ALL' => 'en_US.UTF-8',
  })
end

bash 'Fix frappe dependencies' do
  user node['erpnext']['frappe']['user']
  cwd "/home/#{node['erpnext']['frappe']['user']}/#{node['erpnext']['frappe']['bench']}"
  code <<-EOH
    bench pip install werkzeug==#{node['erpnext']['werkzeug']['version']}
    bench restart
    bench enable-scheduler
EOH
  flags '-eu'
end

# Save initial root password. Will be changed during startup.
file '/mysql_initial_password' do
  content node['erpnext']['mysql-root-password']
end

# Cleanup sudoers file.
file "/etc/sudoers.d/#{node['erpnext']['frappe']['user']}" do
  action :delete
end

# Cleanup passwords file.
file "/home/#{node['erpnext']['frappe']['user']}/passwords.txt" do
  action :delete
end

# Clone bench source code per license requirements.
git '/usr/src/bench' do
  repository 'https://github.com/frappe/bench.git'
  reference 'master'
  action :checkout
end

c2d_startup_script 'erpnext-setup'
