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

execute 'update' do
  command 'apt-get update'
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

  curl -L -O --silent http://updates.jenkins-ci.org/latest/ace-editor.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/antisamy-markup-formatter.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/ant.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/apache-httpcomponents-client-4-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/authentication-tokens.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/bouncycastle-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/branch-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/build-timeout.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/chrome-frame-plugin.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/cloudbees-folder.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/command-launcher.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/credentials-binding.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/credentials.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/config-file-provider.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/display-url-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/docker-commons.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/docker-workflow.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/durable-task.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/email-ext.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/external-monitor-job.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/gcal.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/gcm-notification.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/googleanalytics.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-analytics-usage-reporter.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-api-client-plugin.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-cloud-backup.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-cloud-health-check.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-container-registry-auth.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-deployment-manager.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-git-notes-publisher.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-login.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-metadata-plugin.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-oauth-plugin.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-play-android-publisher.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-source-plugin.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/google-storage-plugin.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/git-client.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/github-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/github-branch-source.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/github.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/github-organization-folder.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/git.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/git-server.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/gradle.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/handlebars.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/icon-shim.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/instant-messaging.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/jackson2-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/jclouds-jenkins.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/jquery.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/jquery-detached.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/jsch.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/junit.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/kubernetes.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/kubernetes-credentials.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/ldap.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/mailer.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/mapdb-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/matrix-auth.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/matrix-project.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/momentjs.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/oauth-credentials.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pam-auth.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-build-step.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-github-lib.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-graph-analysis.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-input-step.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-milestone-step.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-model-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-model-declarative-agent.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-model-definition.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-model-extensions.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-rest-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-stage-step.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-stage-tags-metadata.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/pipeline-stage-view.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/plain-credentials.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/resource-disposer.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/scm-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/script-security.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/ssh-credentials.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/ssh-slaves.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/structs.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/subversion.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/timestamper.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/token-macro.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/variant.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/windows-slaves.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-aggregator.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-basic-steps.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-cps-global-lib.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-cps.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-durable-task-step.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-job.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-multibranch.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-scm-step.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-step-api.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/workflow-support.hpi
  curl -L -O --silent http://updates.jenkins-ci.org/latest/ws-cleanup.hpi

  chown jenkins:jenkins *

EOH
end

c2d_startup_script 'jenkins' do
  source 'jenkins'
  action :cookbook_file
end
