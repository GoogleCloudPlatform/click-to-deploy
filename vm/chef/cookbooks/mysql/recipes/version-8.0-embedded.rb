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
#
# This recipe creates a MySQL VM that is configured to listen on localhost
# and use password authentication for the 'root' user account

node.override['mysql']['log_bin_trust_function_creators'] = '1'

include_recipe 'mysql::version-8.0'

c2d_startup_script 'mysql8-root-localhost-password-setup'
