# Copyright 2018 Google LLC
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
#
# Install and confiugure MySQL packages

package 'install_packages' do
  package_name node['mysql']['packages']
  retries 5
  retry_delay 30
  action :install
end

cookbook_file '/etc/mysql/mysql.conf.d/zz-c2d-bind-address.cnf' do
  source 'zz-c2d-bind-address.cnf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

c2d_startup_script 'mysqld' do
  source 'opt-c2d-scripts-mysqld.erb'
  action :template
end
