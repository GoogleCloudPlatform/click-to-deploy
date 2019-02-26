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

directory '/c2d/'

package 'install unzip' do
  package_name 'zip'
end

execute 'fetch sct' do
  cwd '/c2d'
  command 'curl "https://www.googleapis.com/download/storage/v1/b/schema-conversion-tool/o/install.sh?alt=media" | bash -s linux'
end

# SCT Env Setup
cookbook_file '/etc/default/sct.env' do
  source 'sct.env'
  owner 'root'
  group 'root'
  mode 0777
  action :create
end

# SCT Service Startup
cookbook_file '/etc/init.d/sct' do
  source 'sct'
  owner 'root'
  group 'root'
  mode 0775
  action :create
end

# SCT Setup
cookbook_file '/lib/systemd/system/sct.service' do
  source 'sct.service'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

c2d_startup_script 'sct-startup'
