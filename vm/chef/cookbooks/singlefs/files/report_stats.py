#!/usr/bin/python
"""Additional monitoring for the single node filer."""

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

# TODO(leffler): Integrate into collectd configuration.

import socket
import subprocess
import time

import singlefs_util as util

hostname = socket.gethostname()
stats = []

# Performance numbers on 20 Nov 2015. See this link for details:
# https://cloud.google.com/compute/docs/disks/#pdchart


def pd_standard_throughput_limit(size_in_gbyte):
  """Throughput limit of standard PD in bytes/sec."""
  # On 9 Nov 2015:
  # Per GB: 0.12 MB/s read / 0.09 MB/s write
  # Maximum: 180 MB/s read / 120 MB/s write
  mbyte = 1000 * 1000
  read_throughput_limit = min(180, size_in_gbyte * 0.12) * mbyte
  write_throughput_limit = min(120, size_in_gbyte * 0.09) * mbyte
  return (read_throughput_limit, write_throughput_limit)


def pd_ssd_throughput_limit(size_in_gbyte):
  """Throughput limit of standard PD in bytes/sec."""
  # On 9 Nov 2015:
  # Per GB: 0.48 MB/s read / 0.48 MB/s write
  # Maximum: 240 MB/s read / 240 MB/s write
  mbyte = 1000 * 1000
  read_throughput_limit = min(240, size_in_gbyte * 0.48) * mbyte
  write_throughput_limit = min(240, size_in_gbyte * 0.48) * mbyte
  return (read_throughput_limit, write_throughput_limit)


def local_ssd_throughput_limit(size_in_gbyte):
  """Throughput limit of a local SSD in bytes/sec."""
  # On 14 Nov 2017:
  # Local SSD performance is specified based on iops. Assume 4k requests.
  # Per GB: 453.3 * 4kB/s read = 1.81 MB/s
  # Per GB: 240 * 4kB/s write = 0.96 MB/s
  # Maximum: 2650 MB/s read / 1400 MB/s write
  mbyte = 1000 * 1000
  read_throughput_limit = min(2650, size_in_gbyte * 1.81) * mbyte
  write_throughput_limit = min(1400, size_in_gbyte * 0.96) * mbyte
  return (read_throughput_limit, write_throughput_limit)


def throughput_limit(epoch, name, disk_type, size_in_gbyte):
  if disk_type == 'pd-ssd':
    (read_limit, write_limit) = pd_ssd_throughput_limit(size_in_gbyte)
  elif disk_type == 'pd-standard':
    (read_limit, write_limit) = pd_standard_throughput_limit(size_in_gbyte)
  elif disk_type == 'local-ssd':
    (read_limit, write_limit) = local_ssd_throughput_limit(size_in_gbyte)
  stats.append('collectd.%s.disk-%s.disk_octets.read-limit %d %s' % (
      hostname, name, read_limit, epoch))
  stats.append('collectd.%s.disk-%s.disk_octets.write-limit %d %s' % (
      hostname, name, write_limit, epoch))


def pd_standard_iops_limit(size_in_gbyte):
  """IOps limit of standard PD."""
  # Per GB: 0.3 read / 1.5 write
  # Max per VM: 3000 read / 15000 write
  read_iops_limit = min(3000, int(size_in_gbyte * 0.3))
  write_iops_limit = min(15000, int(size_in_gbyte *  1.5))
  return (read_iops_limit, write_iops_limit)


def pd_ssd_iops_limit(size_in_gbyte):
  """IOps limit of standard PD."""
  # Per GB: 30 read / 30 write
  # Max per VM: 10000 read / 15000 write
  read_iops_limit = min(10000, int(size_in_gbyte * 30))
  write_iops_limit = min(15000, int(size_in_gbyte *  30))
  return (read_iops_limit, write_iops_limit)


def local_ssd_iops_limit(size_in_gbyte):
  """IOps limit of standard PD."""
  # Per GB: 453.3 read / 240 write for NVMe.
  # Max per VM: 680,000 read / 360,000 write
  read_iops_limit = min(680000, int(size_in_gbyte * 453.3))
  write_iops_limit = min(360000, int(size_in_gbyte *  240))
  return (read_iops_limit, write_iops_limit)


def iops_limit(epoch, name, disk_type, size_in_gbyte):
  if disk_type == 'pd-ssd':
    (read_limit, write_limit) = pd_ssd_iops_limit(size_in_gbyte)
  elif disk_type == 'pd-standard':
    (read_limit, write_limit) = pd_standard_iops_limit(size_in_gbyte)
  elif disk_type == 'local-ssd':
    (read_limit, write_limit) = local_ssd_iops_limit(size_in_gbyte)
  stats.append('collectd.%s.disk-%s.disk_ops.read-limit %d %s' % (
      hostname, name, read_limit, epoch))
  stats.append('collectd.%s.disk-%s.disk_ops.write-limit %d %s' % (
      hostname, name, write_limit, epoch))


def main():
  epoch = int(time.time())

  # Assume all storage disks are of the same type. Default to standard PD.
  disk_type = util.storage_disk_type()
  storage_pool = util.storage_pool()
  df_output = subprocess.Popen(
      'df --total /%s | grep -v Filesystem' % (storage_pool),
      shell=True,
      stdout=subprocess.PIPE).stdout.read()
  for line in df_output.split('\n'):
    if line:
      words = line.split()
      name = words[0]
      size_in_gbyte = int(words[1]) / 1000 / 1000
      throughput_limit(epoch, name, disk_type, size_in_gbyte)
      iops_limit(epoch, name, disk_type, size_in_gbyte)

  for line in stats:
    print line

if __name__ == '__main__':
  main()
