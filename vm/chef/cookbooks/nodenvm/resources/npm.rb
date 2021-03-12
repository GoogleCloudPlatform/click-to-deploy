property :package, String, default: ''
property :cwd, String, default: '/'

action :install do
  bash 'Install npm package' do
    code <<-EOH
      source /usr/local/nvm/nvm.sh
      nvm use default
      cd "#{new_resource.cwd}"
      npm install --silent "#{new_resource.package}"
    EOH
  end
end

action :install_global do
  bash 'Install npm package globally' do
    code <<-EOH
      source /usr/local/nvm/nvm.sh
      nvm use default
      echo y | npm install --silent -g "#{new_resource.package}"
    EOH
  end
end
