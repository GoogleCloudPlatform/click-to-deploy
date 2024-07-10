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

remote_file '/tmp/docker-compose' do
  source "https://github.com/docker/compose/releases/download/v#{node['docker']['compose']['version']}/docker-compose-linux-x86_64"
  verify "echo '#{node['docker']['compose']['sha1']} %{path}' | sha1sum -c"
  action :create
end

bash 'install docker compose' do
  user 'root'
  code <<-EOH
    mv /tmp/docker-compose /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    EOH
  environment({
    'version' => node['docker']['compose']['version'],
  })
end
