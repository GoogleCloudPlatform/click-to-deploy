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

include_recipe 'c2d-config'
include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'openjdk8'

execute 'install_jenkins_repo_key' do
  command 'wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -'
end

execute 'add_jenkins_repo' do
  command 'echo "deb http://pkg.jenkins.io/debian-stable binary/" >> /etc/apt/sources.list'
end

apt_update do
  action :update
end

package 'install_packages' do
  package_name node['jenkins']['packages']
  action :install
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

  while [[ ! -d /var/lib/jenkins/plugins ]]; do
    sleep 3
  done

  cd /var/lib/jenkins/plugins
  while [[ ! -e /var/lib/jenkins/jenkins.install.UpgradeWizard.state ]]; do
    sleep 3
  done

  while [[ ! -e /var/lib/jenkins/secrets/initialAdminPassword ]]; do
    sleep 3
  done

  while [[ ! -e /var/lib/jenkins/config.xml ]]; do
    sleep 3
  done

  cp /var/lib/jenkins/jenkins.install.UpgradeWizard.state /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion
  rm /var/lib/jenkins/secrets/initialAdminPassword
  sed -i -e 's/<isSetupComplete>false/<isSetupComplete>true/' -e 's/<installStateName>NEW/<installStateName>RUNNING/' /var/lib/jenkins/config.xml
EOH
end

node['jenkins']['plugins'].each do |plugin|
  bash "install plugin: #{plugin}" do
    code <<-EOH
      curl -L --silent http://updates.jenkins-ci.org/latest/#{plugin}.hpi -o "/var/lib/jenkins/plugins/#{plugin}.jpi"
      chown jenkins:jenkins /var/lib/jenkins/plugins/#{plugin}.jpi
    EOH
  end
end

c2d_startup_script 'jenkins' do
  source 'jenkins'
  action :cookbook_file
end
