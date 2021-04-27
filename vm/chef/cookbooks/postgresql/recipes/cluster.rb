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

include_recipe 'postgresql::standalone'
include_recipe 'bucardo'

cookbook_file "/opt/c2d/pgcluster-utils" do
  source "pgcluster-utils"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/c2d/dump.sql' do
  source 'dump.sql'
  owner 'root'
  group 'root'
  mode 0664
  action :create
end

c2d_startup_script 'postgresql-cluster'
