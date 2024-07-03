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

property :directory, String, default: ''
unified_mode true

action :apply do
  bash 'Create template' do
    user 'root'
    environment({
      'directory' => new_resource.directory,
    })
    code <<-EOH
    cat <<EOT >> /tmp/patch-allow-override
    <Directory $directory>
      AllowOverride All
    </Directory>
  EOH
  end

  bash 'Apply patch' do
    user 'root'
    environment({
      'apacheConfig' => '/etc/apache2/apache2.conf',
    })
    code <<-EOH
line_number="$(cat -n $apacheConfig | grep "/var/www/" | awk '{ print $1 }')"
((line_number=line_number+5))
sed -i "${line_number}r /tmp/patch-allow-override" "$apacheConfig"
EOH
  end
end
