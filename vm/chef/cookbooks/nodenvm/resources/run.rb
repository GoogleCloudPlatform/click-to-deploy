property :command, String, default: ''
property :cwd, String, default: '/'

action :run do
  bash 'Run command in node context' do
    code <<-EOH
      source /usr/local/nvm/nvm.sh
      nvm use default
      cd "#{new_resource.cwd}"
      #{new_resource.command}
    EOH
  end
end
