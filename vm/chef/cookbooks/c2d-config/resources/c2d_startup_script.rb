# Copyright 2022 Google LLC
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
# The resource is responsible for ordering and transferring
# startup scripts to an instance.
#
# Properties:
#   - name     [required] is the name of final startup script name
#                         (without prefix)
#   - source   [optional] is the path to the file/template
#               - default: name property
#   - action   [optional] is the type of resource
#               - default: :cookbook_file
#               - options:
#                 - :cookbook_file
#                 - :template
#
# Examples of using:
#    - Instead of cookbook_file resource:
#
#       c2d_startup_script 'mysql'
#
#    - Instead of templates resource:
#
#       c2d_startup_script 'mysql' do
#         source 'mysqld.erb'
#         action :template
#       end

resource_name :c2d_startup_script
provides :c2d_startup_script

property :source, String, name_property: true, required: true
provides :c2d_startup_script

default_action :cookbook_file

unified_mode true

c2d_startup_count = 0
c2d_startup_dir = '/opt/c2d/scripts'

action :cookbook_file do
  prefix = c2d_startup_count.to_s.rjust(2, '0')

  cookbook_file "#{c2d_startup_dir}/#{prefix}-#{new_resource.name}" do
    source new_resource.source
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  c2d_startup_count += 1
end

action :template do
  prefix = c2d_startup_count.to_s.rjust(2, '0')

  template "#{c2d_startup_dir}/#{prefix}-#{new_resource.name}" do
    source new_resource.source
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  c2d_startup_count += 1
end
