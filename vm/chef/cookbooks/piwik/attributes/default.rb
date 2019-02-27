# Copyright 2018 Google LLC
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

default['piwik']['gpg']['url'] = 'https://debian.piwik.org/repository.gpg'
default['piwik']['gpg']['sha256'] = '0d7c880f6c838bba2d02817dcacfc97fc538b1ebcdb41c3106595265c0d371d4'

default['piwik']['version'] = '3.2.1'

default['piwik']['db']['username'] = 'piwikuser'
default['piwik']['db']['password'] = 'piwikpw'
default['piwik']['db']['name'] = 'piwik'

default['piwik']['app']['first-password'] = `openssl rand -base64 12 | fold -w 12 | head -n1 | tr -d '\r\n'`
