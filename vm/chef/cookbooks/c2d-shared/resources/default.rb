# Copyright 2024 Google LLC
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

resource_name :ospo_download
provides :ospo_download

property :name, String, name_property: true, required: true
property :licenses, String, name_property: false, required: true
property :repos, String, name_property: false, required: false
property :ref_repos, String, name_property: false, required: false

provides :ospo_download

default_action :run

unified_mode true

sources_dir = '/usr/src'
licenses_dir = '/usr/src/licenses'
scripts_dir = '/opt/c2d/ospo'

action :run do
  action_install
  action_prepare
  action_execute_scripts
end

action :install do
  # Create scripts directory
  directory scripts_dir do
    owner 'root'
    group 'root'
    mode '0700'
    action :create
  end

  # Download all scripts
  ['download-licenses', 'download-repos', 'download-ref-repos'].each do |file|
    remote_file "#{scripts_dir}/#{file}.sh" do
      source "https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/#{file}.sh"
      mode '0700'
      action :create
    end
  end
end

action :prepare do
  # Create diretory for storing the licenses and sources
  [ licenses_dir, sources_dir ].each do |dir|
    directory dir do
      owner 'root'
      group 'root'
      mode '0600'
      action :create
    end
  end

  # Create the licenses list
  file "#{licenses_dir}/licenses" do
    content new_resource.licenses
    owner 'root'
    group 'root'
    mode '0600'
  end

  # Create the repositories list
  file "#{sources_dir}/repositories" do
    content new_resource.repos
    owner 'root'
    group 'root'
    mode '0600'
  end

  # Create the repositories reference list
  file "#{sources_dir}/ref-repos" do
    content new_resource.ref_repos
    owner 'root'
    group 'root'
    mode '0600'
  end
end

action :execute_scripts do
  bash 'Download licenses' do
    user 'root'
    cwd '/opt/c2d/ospo'
    environment({
      'licenses_dir' => licenses_dir,
    })
    code <<-EOH
      ./download-licenses.sh $licenses_dir/licenses $licenses_dir
  EOH
  end

  bash 'Download repositories reference' do
    user 'root'
    cwd '/opt/c2d/ospo'
    environment({
      'sources_dir' => sources_dir,
    })
    code <<-EOH
      ./download-ref-repos.sh $sources_dir/ref-repos $sources_dir
  EOH
  end

  bash 'Download sources' do
    user 'root'
    cwd sources_dir
    environment({
      'sources_dir' => sources_dir,
    })
    code <<-EOH
      /opt/c2d/ospo/download-repos.sh $sources_dir/repositories
  EOH
  end
end
