include_recipe 'apache2'
include_recipe 'apache2::ipv4-listen'
include_recipe 'apache2::ipv6-listen'
include_recipe 'apache2::mod-rewrite'
include_recipe 'apache2::security-config'

service 'apache2' do
  action [ :enable, :restart ]
end
