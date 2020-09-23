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

include_recipe 'c2d-config::default'
include_recipe 'apache2::default'
include_recipe 'apache2::mod-rewrite'
include_recipe 'apache2::rm-index'

apt_update do
  action :update
end

package 'install packages core' do
  package_name node['nagios']['packages']['core']
  action :install
end

package 'install packages plugins' do
  package_name node['nagios']['packages']['plugins']
  action :install
end

# download nagios core
remote_file "/tmp/#{node['nagios']['core']['file']}" do
  source node['nagios']['core']['url']
  action :create
end

# download nagios-plugins
remote_file "/tmp/#{node['nagios']['plugins']['file']}" do
  source node['nagios']['plugins']['url']
  action :create
end

# download NRPE plugin
remote_file "/tmp/#{node['nagios']['nrpe']['file']}" do
  source node['nagios']['nrpe']['url']
  action :create
end

# download NCPA plugin
remote_file "/tmp/#{node['nagios']['ncpa']['file']}" do
  source node['nagios']['ncpa']['url']
  action :create
end

template '/etc/apache2/sites-available/nagios-http-redirect.conf' do
  source 'nagios-http-redirect-conf.erb'
  cookbook 'nagios'
  owner 'root'
  group 'root'
  mode '0644'
end

# configure and build nagios
bash 'configure nagios' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    # copy sources
    cp '#{node['nagios']['core']['file']}' /usr/src/
    cp '#{node['nagios']['plugins']['file']}' /usr/src/
    cp '#{node['nagios']['nrpe']['file']}' /usr/src/
    cp '#{node['nagios']['ncpa']['file']}' /usr/src/
    cd /usr/src/
    tar -xf '#{node['nagios']['core']['file']}'
    tar -xf '#{node['nagios']['plugins']['file']}'
    tar -xf '#{node['nagios']['nrpe']['file']}'
    cd -

    # install nagios core
    tar -xf '#{node['nagios']['core']['file']}'
    cd '#{node['nagios']['core']['dir']}'
    ./configure -with-httpd-conf=/etc/apache2/sites-enabled
    make all

    make install-groups-users
    usermod -a -G nagios www-data

    make install
    make install-daemoninit

    make install-commandmode
    make install-config
    make install-webconf
    cd ../

    # install nagios-plugins
    tar -xf '#{node['nagios']['plugins']['file']}'
    cd '#{node['nagios']['plugins']['dir']}'
    ./tools/setup
    ./configure
    make all
    make install
    cd ../

    # install NRPE plugin
    tar -xf '#{node['nagios']['nrpe']['file']}'
    cd '#{node['nagios']['nrpe']['dir']}'
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ./configure
    make all
    make install-plugin
    cd ../

    # install NCPA plugin
    tar -xf '#{node['nagios']['ncpa']['file']}'
    cp check_ncpa.py /usr/local/nagios/libexec
    chown root:nagios /usr/local/nagios/libexec/check_ncpa.py
    chmod 755 /usr/local/nagios/libexec/check_ncpa.py

    a2enmod cgi ssl
    a2dissite 000-default
    a2ensite default-ssl nagios-http-redirect
EOH
end

service 'apache2' do
  action [ :enable ]
end

service 'nagios' do
  action [ :enable ]
end

c2d_startup_script 'nagios' do
  source 'opt-c2d-scripts-nagios.erb'
  action :template
end
