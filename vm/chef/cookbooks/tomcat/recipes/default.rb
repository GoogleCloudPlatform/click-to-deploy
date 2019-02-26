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
# Reference: https://www.linode.com/docs/websites/frameworks/apache-tomcat-on-ubuntu-16-04
# Reference: https://packages.debian.org/jessie/tomcat8
# Reference: https://www.mkyong.com/tomcat/tomcat-default-administrator-password/

include_recipe 'c2d-config'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'openjdk8'

package 'install tomcat' do
  package_name node['tomcat']['packages']
  action :install
end

package 'install haveged' do
  package_name 'haveged'
  action :install
end

execute 'enable proxy_http' do
  command 'a2enmod proxy_http'
end

template '/etc/apache2/sites-available/tomcat.conf' do
  source 'tomcat.conf.erb'
end

execute 'enable tomcat.conf' do
  command 'a2ensite tomcat.conf'
end

service 'tomcat8' do
  action [ :enable, :restart ]
end

execute 'clear logs' do
  command 'rm /var/lib/tomcat8/logs/*'
end

c2d_startup_script 'tomcat' do
  source 'tomcat'
  action :cookbook_file
end

bash 'add tomcat groups' do
  user 'root'
  code <<-EOH
sed -i -e '$ i \\
\\
  <role rolename="manager-gui"/>\\
  <role rolename="admin-gui"/>\\
' /etc/tomcat8/tomcat-users.xml
EOH
end
