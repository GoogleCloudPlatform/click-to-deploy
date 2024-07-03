# Copyright:: 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

name 'google_cloud_ops_agents_chef'
maintainer 'Google'
license 'Apache-2.0'
description 'Installs/Configures google_cloud_ops_agents_chef'
version '0.1.0'
chef_version '>= 15.0'
issues_url 'https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/issues'
source_url 'https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef'

# What OS are supported
%w( amazon centos debian oracle redhat suse opensuseleap ubuntu windows ).each do |os|
  supports os
end
