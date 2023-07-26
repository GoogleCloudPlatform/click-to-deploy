# Copyright 2023 Google LLC
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

ospo_download 'Licenses and Source-code' do
  repos <<-EOF
https://github.com/paramiko/paramiko.git
https://github.com/psycopg/psycopg2.git
https://github.com/chardet/chardet.git
https://github.com/Fyrd/caniuse
https://github.com/ben-eb/caniuse-lite
https://github.com/kemitchell/spdx-exceptions.json.git
EOF
  licenses <<-EOF
WordPress;https://github.com/WordPress/WordPress/blob/master/license.txt
wp-cli;https://github.com/wp-cli/wp-cli/blob/main/LICENSE
Apache_httpd;https://github.com/apache/httpd/blob/trunk/LICENSE
PHP;https://github.com/php/php-src/blob/master/LICENSE
Zend_Engine;https://github.com/php/php-src/blob/master/Zend/LICENSE
MySQL8;https://github.com/mysql/mysql-server/blob/8.0/LICENSE
EOF
end
