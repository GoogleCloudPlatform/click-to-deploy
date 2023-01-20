# Copyright 2023 Google LLC
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

include_recipe 'postgresql::default'

if node['postgresql']['standalone']['allow_external']
  bash 'configure postgresql' do
    user 'root'
    code <<-EOH
    set -x
    set -e
    echo 'host    all     postgres        0.0.0.0/0          md5' >> /etc/postgresql/*/main/pg_hba.conf
    sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf
  EOH
  end
end
