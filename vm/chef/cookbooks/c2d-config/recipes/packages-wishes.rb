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
# Packages wishes contains list of packages with we want to have on all images
# installed by default.

apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

package 'install_packages' do
  package_name node['c2d-config']['common-packages']
  retries 5
  retry_delay 30
  action :install
end
