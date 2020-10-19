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

bash 'Assign IPv6 only' do
  user 'root'
  code <<-EOH
    PORTS_FILE="/etc/apache2/ports.conf"
    LINE_NUMBER="$(cat "${PORTS_FILE}" -n | grep -E "Listen(.*)\:80" | awk '{ print $1 }')"
    LISTEN_CONFIG="Listen [::]:80"

    sed -e "${LINE_NUMBER}i${LISTEN_CONFIG}" -i "${PORTS_FILE}"
  EOH
end
