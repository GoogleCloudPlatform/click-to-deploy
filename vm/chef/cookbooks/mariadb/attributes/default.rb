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

# Remember to check if repo component update
# is needed when changing the version.
default['mariadb']['version'] = '10.11'
default['mariadb']['apt_version'] = "1:#{default['mariadb']['version']}.*"

default['mariadb']['repo']['uri'] = "https://ftp.icm.edu.pl/pub/unix/database/mariadb/repo/#{default['mariadb']['version']}/debian"
default['mariadb']['repo']['distribution'] = 'bullseye'
default['mariadb']['repo']['components'] = ['main']
default['mariadb']['repo']['keyserver'] = 'https://mariadb.org/mariadb_release_signing_key.asc'
