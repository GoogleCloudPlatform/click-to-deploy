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

include_recipe 'c2d-config::create-self-signed-certificate'

apt_repository 'grafana' do
  uri node['grafana']['repo']['uri']
  components node['grafana']['repo']['components']
  distribution node['grafana']['repo']['distribution']
  key node['grafana']['repo']['key']
end

apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

apt_preference 'grafana' do
  pin          "version #{node['grafana']['apt_version']}"
  pin_priority '1000'
end

package 'grafana' do
  :install
end

c2d_startup_script 'grafana'
