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
#
# MySQL v8.0 installation and configuration recipe

include_recipe 'mysql::configure-apt-repo-version-8.0'
include_recipe 'mysql::install-and-configure-mysqld8'

ospo_download 'Licenses and Source-code' do
  licenses <<-EOF
MySQL8;https://github.com/mysql/mysql-server/blob/8.0/LICENSE
curl;https://github.com/mysql/mysql-server/blob/8.0/extra/curl/curl-7.88.1/COPYING
Duktape;https://github.com/mysql/mysql-server/blob/8.0/extra/duktape/duktape-2.7.0/LICENSE.txt
googletest;https://github.com/google/googletest/blob/main/LICENSE
libcbor;https://github.com/mysql/mysql-server/blob/8.0/extra/libcbor/LICENSE.md
libedit;https://github.com/mysql/mysql-server/blob/8.0/extra/libedit/libedit-20210910-3.1/COPYING
libevent;https://github.com/mysql/mysql-server/blob/8.0/extra/libevent/libevent-2.1.11-stable/LICENSE
libfido;https://github.com/mysql/mysql-server/blob/8.0/extra/libfido2/libfido2-1.8.0/LICENSE
lz4;https://github.com/mysql/mysql-server/blob/8.0/extra/lz4/lz4-1.9.4/LICENSE
protobuf;https://github.com/mysql/mysql-server/blob/8.0/extra/protobuf/protobuf-3.19.4/LICENSE
rapidjson;https://github.com/mysql/mysql-server/blob/8.0/extra/rapidjson/license.txt
RobinhoodHashing;https://github.com/mysql/mysql-server/blob/8.0/extra/robin-hood-hashing/LICENSE
zlib;https://github.com/mysql/mysql-server/blob/8.0/extra/zlib/zlib-1.2.13/LICENSE
zstd;https://github.com/mysql/mysql-server/blob/8.0/extra/zstd/zstd-1.5.0/LICENSE
EOF
  ref_repos <<-EOF
  https://github.com/mysql/mysql-server
EOF
end
