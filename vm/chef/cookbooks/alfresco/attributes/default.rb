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

default['alfresco']['install']['url'] = 'https://download.alfresco.com/cloudfront/release/community/7.1.0.1-build-2669/alfresco-content-services-community-distribution-7.1.0.1.zip'
default['alfresco']['install']['sha256'] = '8a7036b72134a7e685b494f776f3dd1576b380d1ac563ee78d38b2a88107b3f2'


default['alfresco']['search']['install']['url'] = 'https://download.alfresco.com/cloudfront/release/community/SearchServices/2.0.1/alfresco-search-services-2.0.1.zip'
default['alfresco']['search']['install']['sha256'] = '00decf904bf99a0a3dcf4bdfb830f4b3be71cea237683084d5527010574f59be'

default['activemq']['install']['url'] = 'https://downloads.apache.org/activemq/5.16.3/apache-activemq-5.16.3-bin.zip'
default['activemq']['install']['sha256'] = '0aeceabce625dde1b2d9285311dca8e0cd4abf8f384ff1e9983ca775f1f762b4'


default['rm']['install']['url'] = 'https://download.alfresco.com/cloudfront/release/community/RM/3.0.a/alfresco-community.zip'
default['rm']['install']['sha256'] = '6bd10de34698f2edb4811e16546cd1c63afb24438379765a2ecc0a76daad2b2d'


default['alfresco']['db']['username'] = 'alfresco'
default['alfresco']['db']['password'] = 'alfresco'
default['alfresco']['db']['name'] = 'alfresco'
