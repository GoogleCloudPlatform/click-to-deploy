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

require 'spec_helper'

# example output
# mysqld --version
# mysqld  Ver 10.5.5-MariaDB-1:10.5.5+maria~buster-log for debian-linux-gnu on x86_64 (mariadb.org binary distribution)

describe command('mysqld --version') do
  its(:stdout) { should match /mysqld  Ver (\d+\.\d+\.\d+)\-.* for debian-linux-gnu on x86_64 .mariadb.org binary distribution./ }
end
