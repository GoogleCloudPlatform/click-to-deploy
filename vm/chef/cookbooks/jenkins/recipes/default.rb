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

include_recipe 'c2d-config'
include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'openjdk11'
include_recipe 'jenkins::ospo'

apt_update do
  action :update
end

package 'wget' do
  action :install
end

apt_repository 'jenkins_repository' do
  uri node['jenkins']['repo']['uri']
  components node['jenkins']['repo']['components']
  keyserver node['jenkins']['repo']['keyserver']
  distribution nil
  trusted true
end

apt_update do
  action :update
end

package 'install_packages' do
  package_name node['jenkins']['packages']
  action :install
end

apt_package 'install_groovy' do
  package_name 'groovy'
  action :install
  options '--no-install-recommends'
end

template '/etc/apache2/conf-available/jenkins.conf' do
  source 'jenkins-conf.erb'
  cookbook 'jenkins'
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'enable_apache_modules' do
  command 'a2enmod headers proxy proxy_http ssl'
end

execute 'enable-jenkins-config' do
  command 'a2enconf jenkins'
end

service 'apache2' do
  action [ :enable, :restart ]
end

service 'jenkins' do
  action [ :enable, :start ]
end

bash 'configure_jenkins' do
  user 'root'
  code <<-EOH

  sed -i '/^HTTP_PORT/a HTTP_HOST=127.0.0.1' /etc/default/jenkins
  sed -i '/^JENKINS_ARGS/ s/"$/ --httpListenAddress=$HTTP_HOST"/' /etc/default/jenkins
  sed -i '/^JAVA_ARGS/ s/"$/ -Dlog4j2.formatMsgNoLookups=true -Dlog4j2.disable.jmx=true"/' /etc/default/jenkins

  jenkins_version="$(java -jar /usr/share/jenkins/jenkins.war --version 2> /dev/null)"
  echo -n "${jenkins_version}" > /var/lib/jenkins/jenkins.install.UpgradeWizard.state
EOH
end

c2d_startup_script 'jenkins' do
  source 'jenkins'
  action :cookbook_file
end
