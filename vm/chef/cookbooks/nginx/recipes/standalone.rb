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

include_recipe 'mysql::version-8.0-embedded'
include_recipe 'php83'
include_recipe 'php83::module_mysql'

include_recipe 'nginx'
include_recipe 'nginx::ospo'

bash 'Enable default homepage' do
  user 'root'
  cwd '/etc/nginx'
  code <<-EOH
  mv conf.d/default.conf sites-enabled/default.conf
EOH
end
