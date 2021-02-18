

bash 'Install NVM' do
  code <<-EOH
    source /usr/local/nvm/nvm.sh
    nvm install v14 --lts
EOH
end
