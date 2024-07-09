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

ENV['DEBIAN_FRONTEND'] = 'noninteractive'

include_recipe 'apache2'
include_recipe 'apache2::mod-passenger'
include_recipe 'apache2::security-config'
include_recipe 'mysql::version-8.0-embedded'
include_recipe 'rvm'

include_recipe 'redmine::ospo'

apt_update 'update' do
  action :update
end

package 'Install Packages' do
  package_name node['redmine']['packages']
  action :install
end

user node['redmine']['user'] do
  action :create
  shell '/sbin/nologin'
  manage_home true
end

bash 'Grant sudo to redmine user' do
  user 'root'
  cwd '/tmp'
  environment({
    'user' => node['redmine']['user'],
  })
  code <<-EOH
    usermod -aG sudo $user
EOH
end

directory '/opt/redmine' do
  owner node['redmine']['user']
  group node['redmine']['user']
  mode '0755'
  recursive true
  action :create
end

bash 'Download Redmine' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    curl -ks -o /tmp/redmine.tar.gz "https://www.redmine.org/releases/redmine-#{node['redmine']['version']}.tar.gz"
EOH
end

bash 'Extract Redmine' do
  user 'root'
  cwd '/tmp'
  environment({
    'user' => node['redmine']['user'],
  })
  code <<-EOH
    tar --extract \
        --file redmine.tar.gz \
        --directory /opt/redmine \
        --strip-components 1 \
    && chown -R $user:$user /opt/redmine \
    && rm -f redmine.tar.gz
EOH
end

bash 'Configure MySQL database' do
  user 'root'
  code <<-EOH
# Create database
mysql -u root -e "create database $defdb character set utf8mb4;";

# Create user with temp credentials
mysql -u root -e "create user $defuser@localhost identified by 'temp';";

# Grant all privileges to redmine user
mysql -u root -e "grant all privileges on $defdb.* to $defuser@localhost;";
EOH
  environment({
    'defdb' => node['redmine']['db']['name'],
    'defuser' => node['redmine']['db']['user'],
  })
end

# Copy Redmine's database connection configuration template
cookbook_file '/opt/redmine/config/database.yml' do
  source 'database.yml'
  owner node['redmine']['user']
  group node['redmine']['user']
  mode 0640
  action :create
end

template 'Set Redmine Apache configuration' do
  path '/etc/apache2/sites-available/redmine.conf'
  source 'apache-redmine.conf.erb'
  owner 'root'
  group 'root'
  mode '0664'
end

template 'Set default Ruby version' do
  path '/opt/redmine/.ruby-version'
  source 'ruby-version.erb'
  owner 'root'
  group 'root'
  mode '0664'
end

bash 'Install Ruby version required for Redmine' do
  cwd '/opt/redmine'
  user 'root'
  environment({
    'rubyVersion' => node['redmine']['ruby']['version'],
  })
  code <<-EOH
    source /usr/local/rvm/scripts/rvm
    rvm install $rubyVersion
EOH
end

bash 'Redmine Bundle Install' do
  cwd '/opt/redmine'
  user 'redmine'
  environment({
    'rubyVersion' => node['redmine']['ruby']['version'],
  })
  code <<-EOH
    source /usr/local/rvm/scripts/rvm
    rvm use $rubyVersion --default
    bundle install --path vendor/bundle
EOH
end

bash 'Pre-config Redmine' do
  cwd '/opt/redmine'
  user 'redmine'
  environment({
    'rubyVersion' => node['redmine']['ruby']['version'],
  })
  code <<-EOH
    source /usr/local/rvm/scripts/rvm
    rvm use $rubyVersion --default
    echo "gem 'blankslate'" >> Gemfile
    echo "gem 'passenger'" >> Gemfile
    echo "gem 'base64', '0.1.1'" >> Gemfile
    bundle install
EOH
end

bash 'Configure Redmine' do
  user node['redmine']['user']
  cwd '/opt/redmine'
  environment({
    'rubyVersion' => node['redmine']['ruby']['version'],
  })
  code <<-EOH
    source /usr/local/rvm/scripts/rvm
    rvm use $rubyVersion --default

    # Define default properties
    export RAILS_ENV="production"
    export REDMINE_LANG="en"

    # Generate token for cookie signing
    bundle exec rake generate_secret_token

    # Create database
    bundle exec rake db:migrate

    # Seed initial data
    bundle exec rake redmine:load_default_data
EOH
end

# Configure Redmine site in Apache and enable it with Apache's passenger module
bash 'Configure Apache Website' do
  user 'root'
  environment({
    'user' => node['redmine']['user'],
  })
  code <<-EOH
# Run Apache as redmine user
sed -i "s/www-data/$user/g" /etc/apache2/envvars

# Disable default website
a2dissite 000-default.conf

# Enable Redmine website
a2ensite redmine.conf
EOH
end

bash 'Configure permissions' do
  user 'root'
  cwd '/opt/redmine'
  environment({
    'user' => node['redmine']['user'],
  })
  code <<-EOH
ln -s /opt/redmine /var/www/html \
  && chmod -R 775 ./* \
  && chown -R $user:$user ./* \
  && chown -R nobody:nogroup files log tmp public/plugin_assets \
  && chmod -R 775 files log tmp public/plugin_assets
EOH
end

# Reload Apache in order to apply the configurations
service 'reload_apache2' do
  service_name 'apache2'
  action [ :reload ]
end

# Remove all AGPL licensed packages installed automatically by Redmine.
package node['redmine']['agpl_packages'] do
  action :remove
  retries 10
  retry_delay 60
end

# Copy post-deploy configuration script (to override and configure instance's specific passwords):
c2d_startup_script 'redmine' do
  source 'redmine-startup'
  action :cookbook_file
end
