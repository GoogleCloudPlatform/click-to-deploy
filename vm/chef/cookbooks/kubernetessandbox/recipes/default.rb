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

package 'Install dependencies packages' do
  package_name node['kubernetes']['dependencies']['packages']
  action :install
end

package 'Install kubernetes packages' do
  package_name node['kubernetes']['packages']
  version node['kubernetes']['version']
  action :install
end

bash 'Hold kubernetes packages version' do
  user 'root'
  code <<-EOH
    apt-get install -y kubelet=${version} && apt-mark hold kubelet kubeadm kubectl containerd.io
EOH
  environment({
    'version' => node['kubernetes']['version'],
  })
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
    ufw allow ${ports}/tcp
    ufw reload
  EOH
  environment({
    'ports' => node['kubernetes']['firewall']['ports'],
  })
end

bash 'Configure containerd' do
  user 'root'
  code <<-EOH
    echo "overlay" >> /etc/modules-load.d/containerd.conf
    echo "br_netfilter" >> /etc/modules-load.d/containerd.conf

    modprobe overlay
    modprobe br_netfilter

    # Setup required sysctl params, these persist across reboots.
    echo "net.bridge.bridge-nf-call-iptables  = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf
    echo "net.ipv4.ip_forward                 = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf
    echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf

    # Apply sysctl params without reboot
    sysctl --system

    mkdir -p /etc/containerd
    containerd config default > /etc/containerd/config.toml
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    systemctl restart containerd
  EOH
end

bash 'Add KUBECONFIG env' do
  user 'root'
  code <<-EOH
    echo 'export KUBECONFIG="/etc/kubernetes/admin.conf"' >> /etc/profile
  EOH
end

c2d_startup_script 'kubernetes-setup'
