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

include_recipe 'couchdb::ospo'

bash 'add apache repo' do
  cwd '/tmp'
  code <<-EOH
    echo "deb https://apache.jfrog.io/artifactory/couchdb-deb/ #{node['couchdb']['debian']['codename']} main" >> /etc/apt/sources.list
    curl -L https://couchdb.apache.org/repo/keys.asc | apt-key add -
EOH
end

apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

bash 'preparing user environment and install' do
  cwd '/tmp'
  code <<-EOH
    COUCHDB_PASSWORD=#{node['couchdb']['password']}
    echo "couchdb couchdb/mode select standalone" | debconf-set-selections
    echo "couchdb couchdb/mode seen true" | debconf-set-selections
    echo "couchdb couchdb/cookie string #{node['couchdb']['cookie']}" | debconf-set-selections
    echo "couchdb couchdb/cookie seen true" | debconf-set-selections
    echo "couchdb couchdb/bindaddress string 127.0.0.1" | debconf-set-selections
    echo "couchdb couchdb/bindaddress seen true" | debconf-set-selections
    echo "couchdb couchdb/adminpass password ${COUCHDB_PASSWORD}" | debconf-set-selections
    echo "couchdb couchdb/adminpass seen true" | debconf-set-selections
    echo "couchdb couchdb/adminpass_again password ${COUCHDB_PASSWORD}" | debconf-set-selections
    echo "couchdb couchdb/adminpass_again seen true" | debconf-set-selections
    DEBIAN_FRONTEND=noninteractive apt-get install -y couchdb
EOH
end

service 'couchdb' do
  action [ :enable ]
end

c2d_startup_script 'couchdb'
