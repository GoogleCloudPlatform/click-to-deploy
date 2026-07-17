# Copyright 2020 Google LLC
# Copyright:: Copyright (c) 2016 GitLab Inc
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource_name :gitlab_sysctl
provides :gitlab_sysctl

actions :create
default_action :create

property :value, [Integer, Float, String, nil], default: nil

action :create do
  directory "create /etc/sysctl.d for #{new_resource.name}" do
    path "/etc/sysctl.d"
    mode "0755"
    recursive true
  end

  conf_name = "90-omnibus-gitlab-#{new_resource.name}.conf"

  file "create /opt/gitlab/embedded/etc/#{conf_name} #{new_resource.name}" do
    path "/opt/gitlab/embedded/etc/#{conf_name}"
    content "#{new_resource.name} = #{new_resource.value}\n"
    # notifies :run, "execute[load sysctl conf #{new_resource.name}]", :immediately
  end

  link "/etc/sysctl.d/#{conf_name}" do
    to "/opt/gitlab/embedded/etc/#{conf_name}"
    # notifies :run, "execute[load sysctl conf #{new_resource.name}]", :immediately
  end

  # Load the settings right away
  execute "load sysctl conf #{new_resource.name}" do
    command "sysctl -e --system"
    action :nothing
  end
end
