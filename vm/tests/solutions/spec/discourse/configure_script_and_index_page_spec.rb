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

describe command('export discourse_user_email=test@example.org;
                  export discourse_user_password=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 12 | head -n 1 | tr -d "\n");
                  export discourse_db_password=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 12 | head -n 1 | tr -d "\n");
                  export discourse_hostname=$(hostname);
                  /opt/c2d/scripts/02-discourse-setup') do
  its(:exit_status) { should eq 0 }
end

describe command('curl -L http://$(hostname)/') do
  its(:stdout) { should match /<title>Discourse<\/title>/ }
  its(:exit_status) { should eq 0 }
end
