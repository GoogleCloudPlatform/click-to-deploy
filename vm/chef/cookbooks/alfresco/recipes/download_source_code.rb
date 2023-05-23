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
# Download sources according to OSPO spreadsheet.

package 'install_dev_packages' do
  package_name node['alfresco']['src']['temp_packages']
  action :install
end

bash 'download_source_code' do
  cwd '/usr/src'
  code <<-EOH
    function git_download_commit() {
      local dir_name="$1"
      local git_url="$2"
      local git_commit="$3"

      git clone "${git_url}" "${dir_name}"
      cd "${dir_name}"
      git checkout "${git_commit}"
      rm -rf .git*
      cd -
    }

    svn co -r 138109 "${alfresco_url}" alfresco && rm -rf alfresco/.svn

    git_download_commit gytheio "${gytheio_url}" 1f3a811
    git_download_commit jmagick "${jmagick_url}" cbd71f2
    git_download_commit jodconverter "${jodconverter_url}" 59f2635

    wget ${hibernate_url} --directory-prefix hibernate
    wget "${java_geom_url}" --directory-prefix java_geom
    wget "${jid3lib_url}" --directory-prefix jid3lib
    wget "${libwmf_url}" --directory-prefix libwmf
EOH
  environment({
    'alfresco_url' => node['alfresco']['src']['urls']['alfresco_svn'],
    'gytheio_url' => node['alfresco']['src']['urls']['gytheio_git'],
    'hibernate_url' => node['alfresco']['src']['urls']['hibernate_wget'],
    'java_geom_url' => node['alfresco']['src']['urls']['java_geom_wget'],
    'jid3lib_url' => node['alfresco']['src']['urls']['jid3lib_wget'],
    'jmagick_url' => node['alfresco']['src']['urls']['jmagick_git'],
    'jodconverter_url' => node['alfresco']['src']['urls']['jodconverter_git'],
    'libwmf_url' => node['alfresco']['src']['urls']['libwmf_wget'],
  })
end

package 'uninstall_dev_packages' do
  package_name node['alfresco']['src']['temp_packages']
  action :purge
end
