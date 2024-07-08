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

# Copy the script file
cookbook_file '/opt/c2d/upgrade-openssh.sh' do
  source 'upgrade-openssh.sh'
  mode '0755'
  owner 'root'
  group 'root'
end

# Execute the script
bash 'execute_script' do
  code <<-EOH
    /bin/bash '/opt/c2d/upgrade-openssh.sh'
  EOH
  environment({
    'OPENSSH_VERSION': '9.8p1',
  })
end
