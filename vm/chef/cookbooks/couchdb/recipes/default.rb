# Copyright 2020 Google LLC
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

bash 'add apache repo' do
  cwd '/tmp'
  code <<-EOH
    echo "deb https://apache.bintray.com/couchdb-deb/ #{node['couchdb']['debian']['codename']} main" >> /etc/apt/sources.list
    curl -L https://couchdb.apache.org/repo/bintray-pubkey.asc | apt-key add -
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
    echo "couchdb couchdb/mode select standalone \
    couchdb couchdb/mode seen true \
    couchdb couchdb/bindaddress string 127.0.0.1 \
    couchdb couchdb/bindaddress seen true \
    couchdb couchdb/adminpass password ${COUCHDB_PASSWORD} \
    couchdb couchdb/adminpass seen true \
    couchdb couchdb/adminpass_again password ${COUCHDB_PASSWORD} \
    couchdb couchdb/adminpass_again seen true" | debconf-set-selections
    DEBIAN_FRONTEND=noninteractive apt-get install -y couchdb
EOH
end

service 'couchdb' do
  action [ :enable ]
end

c2d_startup_script 'couchdb'
