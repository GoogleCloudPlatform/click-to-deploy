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
# Reference: https://cloud.google.com/logging/docs/agent/installation#joint-install

# Download Stackdriver Logging agent
remote_file '/tmp/install-logging-agent.sh' do
  source 'https://dl.google.com/cloudagents/install-logging-agent.sh'
  action :create
end

# Install Stackdriver Logging agent
execute 'bash /tmp/install-logging-agent.sh'
