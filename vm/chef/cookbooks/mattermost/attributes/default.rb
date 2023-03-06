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

default['mattermost']['packages'] = ['jq', 'nginx', 'gettext-base']
default['mattermost']['version'] = '7.8.0'
default['mattermost']['sha256'] = 'daed14bed1dfc44e82bb394a13748dc39a1da0ee8af2fb9ae93f3393f08f15c3'

# OS Settings
default['mattermost']['user'] = 'mattermost'
default['mattermost']['password'] = `openssl rand -base64 12 | fold -w 12 | head -n1 | tr -d '\r\n'`

# DB Settings
default['mattermost']['db']['name'] = 'mattermost'

default['mattermost']['certbot']['version'] = '2.3.0'
