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

default['kubernetes']['version'] = '1.22.3-00'
default['kubernetes']['packages'] = ['kubelet', 'kubeadm', 'kubectl']
default['kubernetes']['dependencies']['packages'] = ['ufw',
                                                    'containerd',
                                                    'apt-transport-https',
                                                    'ca-certificates',
                                                    'curl']

default['kubernetes']['repo']['uri'] = 'http://apt.kubernetes.io/'
default['kubernetes']['repo']['components'] = ['main']
default['kubernetes']['repo']['distribution'] = 'kubernetes-xenial'
default['kubernetes']['repo']['keyserver'] = 'https://packages.cloud.google.com/apt/doc/apt-key.gpg'

default['docker']['repo']['uri'] = 'https://download.docker.com/linux/debian'
default['docker']['repo']['components'] = ['stable']
default['docker']['repo']['distribution'] = 'buster'
default['docker']['repo']['keyserver'] = 'https://download.docker.com/linux/debian/gpg'
