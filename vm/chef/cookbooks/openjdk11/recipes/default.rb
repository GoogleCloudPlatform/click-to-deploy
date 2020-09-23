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

apt_update do
  action :update
end

package 'install packages' do # ~FC009
  only_if { node['platform_version'].include? '8.' }
  package_name node['openjdk11']['packages']
  default_release 'jessie-backports'
  action :install
  retries 5
  retry_delay 60
end

package 'install packages' do
  only_if { node['platform_version'].include? '9.' }
  package_name node['openjdk11']['packages']
  default_release 'stretch-backports'
  action :install
  retries 5
  retry_delay 60
end

package 'install packages' do
  only_if { node['platform_version'].include? '10.' }
  package_name node['openjdk11']['packages']
  action :install
  retries 5
  retry_delay 60
end
