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
include_recipe 'jenkins::ospo'
include_recipe 'openjdk17'

apt_update do
  action :update
end

package 'Install deps' do
  package_name ['unzip', 'wget']
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

# Upgrade vulnerable dependencies
bash 'upgrade_ivy' do
  user 'root'
  environment({
    'ivy_version': node['jenkins']['ivy']['version'],
    'download_url': node['jenkins']['ivy']['download_url'],
  })
  code <<-EOH
  mkdir -p /opt/ivy/dist \
    && cd /opt/ivy \
    && curl -L -o ivy.tar.gz "$download_url" \
    && tar -xvf ivy.tar.gz -C dist/ --strip-components=1 \
    && cp dist/ivy-*.jar /usr/share/java \
    && cd / \
    && rm -rf /opt/ivy \
    && rm -f /usr/share/java/ivy-*.jar \
    && ln -s -f /usr/share/java/ivy-$ivy_version.jar /usr/share/java/ivy.jar
EOH
end

bash 'upgrade_xstream' do
  user 'root'
  environment({
    'xstream_version': node['jenkins']['xstream']['version'],
    'download_url': node['jenkins']['xstream']['download_url'],
  })
  code <<-EOH
  mkdir -p /opt/xstream \
  && cd /opt/xstream \
  && curl -L -o xstream.zip "$download_url" \
  && unzip xstream.zip \
  && cp xstream-$xstream_version/lib/xstream-$xstream_version.jar /usr/share/java/ \
  && rm -f /usr/share/java/xstream-*.jar \
  && ln -s -f /usr/share/java/xstream-$xstream_version.jar /usr/share/java/xstream.jar
EOH
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
