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
#
# Reference: https://docs.weblate.org/en/latest/admin/install/venv-debian.html

include_recipe 'apache2'
include_recipe 'apache2::mod-wsgi'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'redis::standalone'
include_recipe 'postgresql'
include_recipe 'git'

apt_update do
  action :update
end

package 'Install dependencies' do
  package_name node['weblate']['packages']
  action :install
end

# Clone Weblate source code per license requirements.
git '/usr/src/weblate' do
  repository 'https://github.com/WeblateOrg/weblate.git'
  reference "weblate-#{node['weblate']['version']}"
  action :checkout
end

bash 'Install Weblate' do
  user 'root'
  code <<-EOH
    virtualenv --python=python3 /opt/weblate-env
    source /opt/weblate-env/bin/activate
    pip install Weblate psycopg2-binary
    pip install ruamel.yaml aeidon boto3 zeep chardet tesserocr
EOH
end

cookbook_file '/opt/c2d/settings_template.py' do
  source 'settings_template.py'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

c2d_startup_script 'weblate'
