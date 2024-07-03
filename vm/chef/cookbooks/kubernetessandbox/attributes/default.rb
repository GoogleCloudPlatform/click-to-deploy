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

default['kubernetes']['version'] = '1.27.0-00'
default['kubernetes']['packages'] = ['kubelet', 'kubeadm', 'kubectl']
default['kubernetes']['dependencies']['packages'] = ['ufw', 'containerd.io', 'apt-transport-https', 'ca-certificates', 'curl']

default['kubernetes']['repo']['uri'] = 'http://apt.kubernetes.io/'
default['kubernetes']['repo']['components'] = ['main']
default['kubernetes']['repo']['distribution'] = 'kubernetes-xenial'
default['kubernetes']['repo']['keyserver'] = 'https://packages.cloud.google.com/apt/doc/apt-key.gpg'
default['kubernetes']['firewall']['ports'] = '22,6443,2379,2380,10250,10251,10252,10255'

default['docker']['repo']['uri'] = 'https://download.docker.com/linux/debian'
default['docker']['repo']['components'] = ['stable']
default['docker']['repo']['distribution'] = 'bullseye'
default['docker']['repo']['keyserver'] = 'https://download.docker.com/linux/debian/gpg'
