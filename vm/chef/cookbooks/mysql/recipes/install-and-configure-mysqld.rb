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

package 'install_packages' do
  package_name node['mysql']['packages']
  retries 5
  retry_delay 30
  action :install
end

template '/etc/mysql/mysql.conf.d/mysqld.cnf' do
  source 'mysqld.cnf.erb'
  variables({
    bind_address: node['mysql']['bind_address'],
    log_bin_trust_function_creators: node['mysql']['log_bin_trust_function_creators'],
  })
end

c2d_startup_script 'mysql'

bash 'rm_test_db_and_users' do
  user 'root'
  code <<-EOH
    mysql -u root -e "DROP DATABASE IF EXISTS test;"
    mysql -u root -e "DELETE FROM mysql.user WHERE User != 'mysql.sys' AND User != 'root'"
  EOH
end
