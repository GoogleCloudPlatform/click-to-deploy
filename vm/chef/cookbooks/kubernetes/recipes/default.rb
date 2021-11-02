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
#
# Reference: https://github.com/opencart/opencart/blob/master/INSTALL.md
#include_recipe 'apache2'
#include_recipe 'apache2::rm-index'
#include_recipe 'apache2::security-config'
#include_recipe 'mysql'

# Reference: https://docs.opencart.com/requirements/
#include_recipe 'php74'
#include_recipe 'php74::module_curl'
#include_recipe 'php74::module_gd'
#include_recipe 'php74::module_json'
#include_recipe 'php74::module_libapache2'
#include_recipe 'php74::module_mbstring'
#include_recipe 'php74::module_mysql'
#include_recipe 'php74::module_opcache'
#include_recipe 'php74::module_xml'
#include_recipe 'php74::module_zip'
#include_recipe 'composer'
#include_recipe 'git'
#
apt_repository 'docker_repository' do
  uri node['docker']['repo']['uri']
  components node['docker']['repo']['components']
  keyserver node['docker']['repo']['keyserver']
  distribution node['docker']['repo']['distribution']
  trusted true
end

apt_repository 'kubernetes_repository' do
  uri node['kubernetes']['repo']['uri']
  components node['kubernetes']['repo']['components']
  keyserver node['kubernetes']['repo']['keyserver']
  distribution node['kubernetes']['repo']['distribution']
  trusted true
end

apt_update do
  action :update
end

package 'Install Packages' do
  package_name node['kubernetes']['packages']
  action :install
end

bash 'Disable swap memory' do
  user 'root'
  code <<-EOH
    swapoff -a
    # Disable swapoff in /etc/fstab
    sed -i 's@/swap.img@#/swap.img@g' /etc/fstab
  EOH
end

bash 'Switching to iptable for nftables backend compatibility' do
  user 'root'
  code <<-EOH
    update-alternatives --set iptables /usr/sbin/iptables-legacy
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
    update-alternatives --set arptables /usr/sbin/arptables-legacy
    update-alternatives --set ebtables /usr/sbin/ebtables-legacy
  EOH
end

bash 'Adding rules to firewall' do
  user 'root'
  code <<-EOH
    ufw allow 6443/tcp
    ufw allow 2379/tcp
    ufw allow 2380/tcp
    ufw allow 10250/tcp
    ufw allow 10251/tcp
    ufw allow 10252/tcp
    ufw allow 10255/tcp
    ufw reload
  EOH
end


bash 'Configure containerd' do
  user 'root'
  code <<-EOH
    cat <<EOF | tee /etc/modules-load.d/containerd.conf
    overlay
    br_netfilter
    EOF

    modprobe overlay
    modprobe br_netfilter

    cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
    net.bridge.bridge-nf-call-iptables = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward = 1
    EOF

    sysctl --system

    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml
    systemctl restart containerd
  EOH
end




# Install containerd as container runtime for kubernetes sandbox

#


# Clone OpenCart source code per license requirements.
#git '/usr/src/opencart' do
#  repository 'https://github.com/opencart/opencart.git'
#  reference node['opencart']['version']
#  action :checkout
#end
#
#bash 'Configure Database' do
#  user 'root'
#  cwd '/var/www/html'
#  code <<-EOH
## create db
#mysql -u root -e "CREATE DATABASE $defdb CHARACTER SET utf8 COLLATE utf8_general_ci";
#EOH
#  environment({
#    'defdb' => node['opencart']['db']['name'],
#  })
#end

# Copy the utils file for opencart startup
#cookbook_file '/opt/c2d/opencart-utils' do
#  source 'opencart-utils'
#  owner 'root'
#  group 'root'
#  mode 0644
#  action :create
#end
#
#apache2_allow_override 'Allow override' do
#  directory '/var/www/html'
#end
#
#execute 'enable apache modules' do
#  command 'a2enmod rewrite'
#end
#
#c2d_startup_script 'opencart'
#