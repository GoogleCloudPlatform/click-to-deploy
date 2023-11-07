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

node.override['postgresql']['standalone']['allow_external'] = false

include_recipe 'git'
include_recipe 'postgresql::standalone_bullseye'
include_recipe 'rvm'

apt_update 'update'

package 'Install packages' do
  package_name node['discourse']['packages']
  action :install
end

cookbook_file '/tmp/nginx-install' do
  source 'nginx-install'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

execute 'Build nginx with custom modules' do
  command '/tmp/nginx-install'
end

user 'discourse' do
  action :create
  home '/home/discourse'
  shell '/bin/bash'
  manage_home true
end

git '/var/www/discourse' do
  repository 'https://github.com/discourse/discourse'
  revision "v#{node['discourse']['version']}"
  action :checkout
end

bash 'Discourse Install Ruby environment' do
  user 'root'
  environment({
    'rubyVersion' => node['discourse']['ruby']['version'],
    'bundlerVersion' => node['discourse']['bundler']['version'],
  })
  code <<-EOH
      source /usr/local/rvm/scripts/rvm
      rvm install ruby-${rubyVersion}
      rvm --default use ${rubyVersion}

      gem install bundler -v "${bundlerVersion}"
EOH
end

bash 'Create Discourse DB and user' do
  user 'postgres'
  code <<-EOH
    psql -c "CREATE DATABASE discoursedb;"
    psql -c "CREATE USER discourse;"
    psql -c "ALTER USER discourse WITH ENCRYPTED PASSWORD 'tmp_build_password';"
    psql -c "ALTER DATABASE discoursedb OWNER TO discourse;"
    psql discoursedb -c "CREATE EXTENSION hstore; CREATE EXTENSION pg_trgm;"
EOH
end

bash 'Update DB credentials' do
  user 'root'
  code <<-EOH
    export CONFIG="/var/www/discourse/config/discourse_defaults.conf"
    sed -i 's/db_host =.*/db_host = localhost/' ${CONFIG}
    sed -i 's/db_name =.*/db_name = discoursedb/' ${CONFIG}
    sed -i 's/db_password =.*/db_password = tmp_build_password/' ${CONFIG}
EOH
end

bash 'Change directory owner' do
  cwd '/var/www/discourse'
  user 'root'
  code <<-EOH
      chown -R discourse:discourse /var/www/discourse
EOH
end

bash 'Discourse Bundle Install' do
  cwd '/var/www/discourse'
  user 'discourse'
  code <<-EOH
      # disable brotli compression
      sed -i 's/^\s*brotli(path, max_compress)$/# brotli(path, max_compress)/' /var/www/discourse/lib/tasks/assets.rake

      # run bundle installation
      source /usr/local/rvm/scripts/rvm

      bundle config set --local deployment 'true'
      bundle config set --local without 'test development'
      bundle install --jobs 4

      mkdir -p /home/discourse/discourse/tmp/sockets \
               /home/discourse/discourse/tmp/pids \
               /home/discourse/discourse/log
EOH
end

service 'redis-server' do
  action :start
end

bash 'Discourse DB Migrate and precompile assets precompile' do
  cwd '/var/www/discourse'
  user 'discourse'
  code <<-EOH
    source /usr/local/rvm/scripts/rvm

    export RAILS_ENV=production
    bundle exec rake db:migrate
    bundle exec rake assets:precompile
EOH
end

bash 'Nginx config updates' do
  cwd '/tmp'
  user 'root'
  code <<-EOH
    cp /var/www/discourse/config/nginx.sample.conf /etc/nginx/conf.d/discourse.conf
    sed -i '0,/server unix:\\/var\\/www\\/discourse.*/s//server unix:\\/home\\/discourse\\/discourse\\/tmp\\/sockets\\/puma.sock;/' /etc/nginx/conf.d/discourse.conf
    sed -i '/server unix:\\/var\\/www\\/discourse.*/d' /etc/nginx/conf.d/discourse.conf
EOH
end

cookbook_file '/etc/systemd/system/puma.service' do
  source 'puma.service'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

service 'puma.service' do
  action [ :enable, :stop ]
end

c2d_startup_script 'discourse-setup'
