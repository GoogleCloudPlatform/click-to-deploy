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

default['tomcat']['version'] = '10.1.20'
default['tomcat']['sha256'] = '8427c5509f14e482940a015f3f60de20342d3d72c8dea9982a4d7112cb71a6ee'

default['tomcat']['app']['install_dir'] = '/opt/tomcat'

default['tomcat']['user'] = 'tomcat'
