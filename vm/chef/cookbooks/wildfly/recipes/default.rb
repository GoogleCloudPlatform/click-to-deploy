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

include_recipe 'openjdk11'

apt_update 'update' do
  action :update
end

# Install the package required to apt-get update with elasticsearch repo
package 'apt-transport-https' do
  action :install
end

user node['wildfly']['user'] do
  action :create
  home "/home/#{node['wildfly']['user']}"
  password node['wildfly']['password']
  shell '/bin/bash'
  manage_home true
end

# https://hub.docker.com/r/jboss/wildfly/dockerfile
bash 'Install Wildfly' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mkdir -p $JBOSS_HOME \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:jboss ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}
EOH
end

# https://bgasparotto.com/start-stop-restart-wildfly/
# https://stackoverflow.com/questions/42907443/wildfly-as-systemd-service
cookbook_file '/lib/systemd/system/wildfly.service' do
  source 'wildfly.service'
  owner 'root'
  group 'root'
  mode 0664
  action :create
end

service 'wildfly.service' do
  action [ :enable, :stop ]
end

# mattermost service setup


# Copy startup script
c2d_startup_script 'wildfly'
