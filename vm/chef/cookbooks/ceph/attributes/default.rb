# Copyright 2023 Google LLC
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

default['ceph']['version'] = 'quincy'
default['ceph']['deploymentuser'] = 'cephdep'

default['ceph']['adminnodepackages'] = %w(cephadm rsync)
default['ceph']['datanodepackages'] = %w(catatonit podman lvm2 rsync)

default['ceph']['config-dir'] = "#{node['c2d-config']['config-dir']}/#{node['ceph']['deploymentuser']}"

default['ceph']['rsync-dir-name'] = 'data-node-config'
default['ceph']['rsync-dir'] = "#{node['ceph']['config-dir']}/#{node['ceph']['rsync-dir-name']}"
