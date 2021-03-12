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

include_recipe 'meanstack::default'

nodenvm_npm 'Install Angular' do
  action :install_global
  package "@angular/cli@#{node['meanstack']['angular']['version']}"
end

nodenvm_run 'Create Angular Web Application' do
  cwd '/sites'
  command "ng new web --create-application --defaults --interactive=false"
end
