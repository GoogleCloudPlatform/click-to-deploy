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

require 'net/http'

# Find latest version for Solr 8
uri = URI('https://downloads.apache.org/lucene/solr/')
response = Net::HTTP.get(uri)
match = response.match /(?<version>8\.\d+\.\d+)/

default['solr']['version'] = match[:version]
default['solr']['packages'] = ['lsof']
