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

include_recipe 'c2d-config::default'
include_recipe 'apache2::mod-wsgi'

apt_update do
  action :update
end

package node['django']['packages']

bash 'install django via pip3' do
  user 'root'
  code <<-EOH
    pip3 install django gunicorn
EOH
end

execute 'enable_apache_modules' do
  command 'a2enmod proxy proxy_http'
end

template '/etc/apache2/sites-available/django.conf' do
  source 'django.conf.erb'
  action :create
  owner 'root'
  group 'root'
  mode '0644'
end

c2d_startup_script 'django-config-setup'
