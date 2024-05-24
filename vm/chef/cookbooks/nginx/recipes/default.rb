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

# Install NGINX package
apt_repository 'nginx' do
  uri node['nginx']['repo']['uri']
  components node['nginx']['repo']['components']
  distribution node['nginx']['repo']['distribution']
  key node['nginx']['repo']['keyserver']
end

apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

package 'install packages' do
  package_name node['nginx']['packages']
  action :install
end

# Create default folders
['available', 'enabled'].each do |dir|
  directory "/etc/nginx/sites-#{dir}" do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

# Include sites-enabled/ folder to default configuration and set user
bash 'Configure NGINX' do
  user 'root'
  cwd '/etc/nginx'
  code <<-EOH

  grep "include /etc/nginx/sites-enabled" nginx.conf > /dev/null || sed -i "/^.*include.*conf.d/a \ \ \ \ include /etc/nginx/sites-enabled/*.conf;" nginx.conf
  sed -i 's/user \ nginx;/user www-data;/g' nginx.conf
EOH
end

service 'nginx' do
  action :reload
end
