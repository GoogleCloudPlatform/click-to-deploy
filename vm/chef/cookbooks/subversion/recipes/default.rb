# Copyright 2021 Google LLC
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

include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'

apt_update do
  action :update
end

package 'install_packages' do
  package_name node['subversion']['packages']
  action :install
end

['dav', 'dav_svn'].each do |apache_module|
  execute 'Enable apache modules' do
    command "a2enmod #{apache_module}"
  end
end

cookbook_file '/etc/apache2/mods-available/dav_svn.conf' do
  source 'dav_svn.conf'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

service 'apache2' do
  action [ :enable, :restart ]
end

c2d_startup_script 'subversion'
