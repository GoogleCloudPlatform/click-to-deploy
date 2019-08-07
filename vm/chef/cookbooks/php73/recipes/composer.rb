# Copyright 2019 Google LLC
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

include_recipe 'php73::module_cgi'
include_recipe 'php73::module_curl'
include_recipe 'php73::module_gd'
include_recipe 'php73::module_intl'
include_recipe 'php73::module_mbstring'
include_recipe 'php73::module_xml'
include_recipe 'php73::module_xsl'
include_recipe 'php73::module_zip'
