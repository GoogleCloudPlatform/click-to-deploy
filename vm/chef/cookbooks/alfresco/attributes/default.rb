# Copyright 2018 Google LLC
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

default['alfresco']['install']['url'] = 'https://download.alfresco.com/release/community/201707-build-00028/alfresco-community-installer-201707-linux-x64.bin'
default['alfresco']['install']['sha256'] = '099d2f26c593e58fe640e714e561d317b8ad3458bd361020796ed79a41a4f259'

default['alfresco']['db']['username'] = 'alfresco'
default['alfresco']['db']['password'] = 'alfresco'
default['alfresco']['db']['name'] = 'alfresco'

default['alfresco']['src']['temp_packages'] = ['subversion', 'git']

# Downloading jmagick and jodconverter from fork,
# because original repositories are no longer available
default['alfresco']['src']['urls'] = {
  'alfresco_svn' => 'https://svn.alfresco.com/repos/alfresco-open-mirror/alfresco/COMMUNITYTAGS/5.2.f/root',

  'gytheio_git' => 'git://github.com/Alfresco/gytheio.git',
  'jmagick_git' => 'git://github.com/techblue/jmagick.git',
  'jodconverter_git' => 'git://github.com/mirkonasato/jodconverter.git',

  'hibernate_wget' => 'https://downloads.sourceforge.net/project/hibernate/hibernate3/3.2.6.ga/hibernate-3.2.6.ga.tar.gz',
  'java_geom_wget' => 'https://downloads.sourceforge.net/project/geom-java/javaGeom/javaGeom-0.11.2/javaGeom-0.11.2-src.zip',
  'jid3lib_wget' => 'https://downloads.sourceforge.net/project/javamusictag/jid3lib/beta-dev6/jid3lib-0.5.4.tar.gz',
  'libwmf_wget' => 'https://sourceforge.net/projects/wvware/files/libwmf/0.2.8.4/libwmf-0.2.8.4.tar.gz',
}
