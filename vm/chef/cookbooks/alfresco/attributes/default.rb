# Copyright 2021 Google LLC
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

default['alfresco']['install']['url'] = 'https://download.alfresco.com/cloudfront/release/community/7.0.0-build-2355/alfresco-content-services-community-distribution-7.0.0.zip'
default['alfresco']['install']['sha256'] = 'f961b1de1756d88b0cce9e856c1f63c670bd82372b803c6ee9bb6d103f3393ca'


default['alfresco']['search']['install']['url'] = 'https://download.alfresco.com/cloudfront/release/community/SearchServices/2.0.1/alfresco-search-services-2.0.1.zip'
default['alfresco']['search']['install']['sha256'] = '00decf904bf99a0a3dcf4bdfb830f4b3be71cea237683084d5527010574f59be'

default['alfresco']['db']['username'] = 'alfresco'
default['alfresco']['db']['password'] = 'alfresco'
default['alfresco']['db']['name'] = 'alfresco'
