#!/usr/bin/python
"""Utility functions."""

# Copyright 2019 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import json
import multiprocessing
import urllib2

# GCE metadata constants
DEFAULT_HEADERS={'Metadata-Flavor': 'Google'}
METADATA_URL='http://metadata.google.internal/computeMetadata/v1/'
INSTANCE_URL=METADATA_URL + 'instance'
ATTRIBUTES_URL=INSTANCE_URL + '/attributes'
ZONE_URL=METADATA_URL + 'instance/zone'
PROJECT_ID_URL=METADATA_URL + 'project/project-id'
TOKEN_URL=METADATA_URL + 'instance/service-accounts/default/token'
INSTANCE_NETWORK_URL=METADATA_URL + 'instance/network-interfaces/0/network'
COMPUTE_METADATA_BASE='https://www.googleapis.com/compute/v1/'
NETWORK_URL=(COMPUTE_METADATA_BASE +
             'projects/%(project)s/global/networks/%(network)s')


def system_info():
  meminfo = open('/proc/meminfo')
  for line in meminfo:
    words = line.split()
    if words[0] == 'MemTotal:':
      memtotal = int(words[1]) * 1024
  meminfo.close()
  return (memtotal, multiprocessing.cpu_count())


def request_text(url, headers=None):
  if not headers:
    headers = DEFAULT_HEADERS
  request = urllib2.Request(url=url, headers=headers)
  try:
    response = urllib2.urlopen(request)
    if response.getcode() != 200:
      print 'Error: Request to "%s" returned %d: %s' % (
          url, response.getcode(), response.msg)
      return ''
    return response.read()
  except urllib2.HTTPError:
    return ''


def request_json(url, headers=None):
  response = request_text(url, headers)
  return json.loads(response)


def request_metadata(category, headers=None):
  url = '%s/%s/?recursive=true ' % (INSTANCE_URL, category)
  return request_json(url, headers)


def get_metadata(attribute):
  url = '%s/%s' % (ATTRIBUTES_URL, attribute)
  return request_text(url)


def gce_zone():
  """Return the CGE zone of the instance."""
  zone_info = request_text(ZONE_URL)
  return zone_info.split('/')[-1]


def storage_pool():
  """Return the name of the storage pool."""
  return get_metadata('STORAGE_POOL_NAME')


def network_cidrs():
  """Return the network CIDR for the instance, for example 10.240.0.0/16."""
  access_token = request_json(TOKEN_URL)['access_token']
  network_path = request_text(INSTANCE_NETWORK_URL)
  network_id = network_path.split('/')[3]
  project_id = request_text(PROJECT_ID_URL)

  # Get detailed network info
  network_url = NETWORK_URL % {'project': project_id, 'network': network_id}
  metadata = {'Metadata-Flavor': 'Google',
              'Authorization': 'Bearer ' + access_token}
  network_info = request_json(network_url, headers=metadata)
  cidrs = []

  # Legacy single GCE network
  if 'IPv4Range' in network_info:
    cidrs.append(network_info['IPv4Range'])

  # Newer GCE subnetworks
  if 'subnetworks' in network_info:
    for subnet in network_info['subnetworks']:
      network_info = request_json(subnet, headers=metadata)
      cidrs.append(network_info['ipCidrRange'])

  return cidrs


def storage_disk_type():
  """Return type of storage disk (either pd-standard or pd-ssd)."""
  disks = request_metadata('disks')
  # Assume there is only one data disk.
  for disk in disks:
    # Disk index 0 is always boot disk.
    if disk['mode'] == 'READ_WRITE' and disk['index'] != 0:
      if disk['type'] == 'PERSISTENT':
        return 'pd-standard'
      elif disk['type'] == 'PERSISTENT-SSD':
        return 'pd-ssd'
      else:
        return 'local-ssd'
