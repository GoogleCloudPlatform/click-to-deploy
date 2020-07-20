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

default['jenkins']['packages'] = %w(jenkins git groovy subversion)

# Default plugins to install
default['jenkins']['plugins'] = %w(ace-editor
                                   antisamy-markup-formatter
                                   ant
                                   apache-httpcomponents-client-4-api
                                   authentication-tokens
                                   bouncycastle-api
                                   branch-api
                                   build-timeout
                                   cloudbees-folder
                                   cloud-stats
                                   command-launcher
                                   credentials-binding
                                   credentials
                                   config-file-provider
                                   display-url-api
                                   docker-commons
                                   docker-workflow
                                   durable-task
                                   email-ext
                                   external-monitor-job
                                   gcal
                                   googleanalytics
                                   google-analytics-usage-reporter
                                   google-api-client-plugin
                                   google-cloud-backup
                                   google-cloud-health-check
                                   google-container-registry-auth
                                   google-git-notes-publisher
                                   google-login
                                   google-metadata-plugin
                                   google-oauth-plugin
                                   google-play-android-publisher
                                   google-source-plugin
                                   google-storage-plugin
                                   git-client
                                   github-api
                                   github-branch-source
                                   github
                                   github-organization-folder
                                   git
                                   git-server
                                   gradle
                                   handlebars
                                   icon-shim
                                   instant-messaging
                                   jackson2-api
                                   jclouds-jenkins
                                   jdk-tool
                                   jquery
                                   jquery-detached
                                   jsch
                                   junit
                                   kubernetes
                                   kubernetes-client-api
                                   kubernetes-credentials
                                   ldap
                                   lockable-resources
                                   mailer
                                   mapdb-api
                                   matrix-auth
                                   matrix-project
                                   maven-plugin
                                   momentjs
                                   oauth-credentials
                                   okhttp-api
                                   pam-auth
                                   pipeline-build-step
                                   pipeline-github-lib
                                   pipeline-graph-analysis
                                   pipeline-input-step
                                   pipeline-milestone-step
                                   pipeline-model-api
                                   pipeline-model-definition
                                   pipeline-model-extensions
                                   pipeline-rest-api
                                   pipeline-stage-step
                                   pipeline-stage-tags-metadata
                                   pipeline-stage-view
                                   plain-credentials
                                   resource-disposer
                                   scm-api
                                   script-security
                                   snakeyaml-api
                                   ssh-credentials
                                   ssh-slaves
                                   structs
                                   subversion
                                   timestamper
                                   token-macro
                                   trilead-api
                                   variant
                                   windows-slaves
                                   workflow-aggregator
                                   workflow-api
                                   workflow-basic-steps
                                   workflow-cps-global-lib
                                   workflow-cps
                                   workflow-durable-task-step
                                   workflow-job
                                   workflow-multibranch
                                   workflow-scm-step
                                   workflow-step-api
                                   workflow-support
                                   ws-cleanup
                                  )
