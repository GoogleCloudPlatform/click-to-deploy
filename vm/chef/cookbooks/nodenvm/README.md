# nodenvm Cookbook

### Recipes usage:

Installing nodenvm:
```ruby
include_recipe 'nodenvm'
```

Installing node v14 through nvm:
```ruby
include_recipe 'nodenvm::node14'
```

### Resources usage:

Install a npm package globally:
```ruby
nodenvm_npm 'Install Express Globally' do
  action :install_global
  package "express-generator@4.12.0"
end
```

Run a command in a node environment:
```ruby
nodenvm_run 'Init API Application' do
  cwd '/sites/api'
  command 'npm init --force'
end
```

Install a npm package locally:
```ruby
nodenvm_npm 'Install Mongoose' do
  cwd '/sites/api'
  action :install
  package 'mongoose'
end
```
