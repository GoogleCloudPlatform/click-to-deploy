# Copyright 2019 Google LLC
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

include_recipe 'postgresql'
include_recipe 'nginx'

package 'Install packages' do
  package_name node['odoo']['packages']
  action :install
end

# Download WKHTMLtoPDF from the official server
remote_file '/tmp/wkhtmltopdf.deb' do
  source "https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/#{node['odoo']['wkhtmltopdf']['version']}/wkhtmltox_#{node['odoo']['wkhtmltopdf']['release']}.stretch_amd64.deb"
  checksum node['odoo']['wkhtmltopdf']['sha256']
  action :create
end

bash 'Install wkhtmltox' do
  cwd '/tmp'
  user 'root'
  code <<-EOH
    dpkg --force-depends -i /tmp/wkhtmltopdf.deb\
    && apt-get -y install -f --no-install-recommends
EOH
end

# Download WKHTMLtoPDF source code
# It is downloaded per license requirements.
git '/usr/src/wkhtmltopdf' do
  repository 'https://github.com/wkhtmltopdf/wkhtmltopdf.git'
  revision node['odoo']['wkhtmltopdf']['version']
  action :checkout
end

# Download ODOO from the official server
remote_file '/tmp/odoo.deb' do
  source "http://nightly.odoo.com/#{node['odoo']['version']}/nightly/deb/odoo_#{node['odoo']['version']}.#{node['odoo']['release']}_all.deb"
  checksum node['odoo']['sha256']
  action :create
end

bash 'Install odoo' do
  cwd '/tmp'
  user 'root'
  code <<-EOH
    dpkg --force-depends -i /tmp/odoo.deb \
    && apt-get -y install -f --no-install-recommends
EOH
end

bash 'Bind odoo on the localhost' do
  user 'root'
  code <<-EOH
    echo "xmlrpc_interface = 127.0.0.1" >> /etc/odoo/odoo.conf
EOH
end

# Download ODOO src from the official server
# It is downloaded per license requirements.
remote_file '/tmp/odoo.tar.xz' do
  source "http://nightly.odoo.com/#{node['odoo']['version']}/nightly/deb/odoo_#{node['odoo']['version']}.#{node['odoo']['release']}.tar.xz"
  checksum node['odoo']['src']['sha256']
  action :create
end

bash 'Extract odoo source code' do
  cwd '/tmp'
  user 'root'
  code <<-EOH
    tar xf /tmp/odoo.tar.xz -C /usr/src
EOH
end

bash 'Install python requirements' do
  code "pip3 install #{node['odoo']['pip-packages']}"
  user 'root'
end

template '/etc/nginx/sites-available/default' do
  source 'default-nginx.erb'
end

c2d_startup_script 'odoo-setup'
