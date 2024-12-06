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

default['tomcat']['version'] = '11.0.1'
default['tomcat']['sha256'] = '7e2470ac429434534910940e77d04c6d4c47e3a83d7130128be4d091d8d2ee68'

default['tomcat']['app']['install_dir'] = '/opt/tomcat'

default['tomcat']['user'] = 'tomcat'
