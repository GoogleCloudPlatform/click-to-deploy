#!/bin/bash

declare -r components_file="$1"
declare -r target_folder="$2"

function print_usage() {
  >&2 echo "Script iterate over each component in CSV file and download its licenses"
  >&2 echo "Usage:"
  >&2 echo "./download-licenses.sh licenses.csv /usr/src/licenses"
}

# Validate parameters
if [[ "$#" -eq 2 ]]; then
  if [[ ! -f "${components_file}" ]]; then
    print_usage
    exit 1
  fi
else
  print_usage
  exit 1
fi

function get_domain() {
  echo "$1" | awk -F[/:] '{print $4}'
}

# Converts a web github page to the raw url and download it:
#   https://github.com/qos-ch/slf4j/blob/master/log4j-over-slf4j/LICENSE.txt
#   https://raw.githubusercontent.com/java-native-access/jna/master/LICENSE
function download_github() {
  local -r license_page="$1"
  local -r output_file="$2"

  local -r org_repo_branch="$(echo "${license_page}" | awk -F / '{ print $4"/"$5"/"$7}')"
  local -r github_raw_domain="https://raw.githubusercontent.com"
  local -r file="$(echo "${license_page}" | awk -F / '{ print $NF }')"
  local -r license_download_url="${github_raw_domain}/${org_repo_branch}/${file}"

  curl -sL -o "${output_file}" "${license_download_url}"
  >&2 echo "File downloaded: ${license_download_url}"
}

# Converts a web github page to the raw url and download it:
#   https://gitlab.ow2.org/asm/asm/-/blob/master/LICENSE.txt
#   https://gitlab.ow2.org/asm/asm/-/raw/master/LICENSE.txt
function download_gitlab() {
  local -r license_page="$1"
  local -r output_file="$2"

  local -r license_download_url="$(echo "${license_page}" | sed 's/blob/raw/g')"
  curl -sL -o "${output_file}" "${license_download_url}"
  >&2 echo "File downloaded: ${license_download_url}"
}

function download_html() {
  local -r license_page="$1"
  local -r output_file="$2"

  curl -sL -o "${output_file}" "${license_page}"
  >&2 echo "File downloaded: ${output_file}"
}

# Create target folder
mkdir -p "${target_folder}"

# Iterate over components
while IFS=";" read -r component license
do
  declare target_license_file="${target_folder}/${component}.LICENSE"
  declare domain="$(get_domain "${license}")"

  if [[ "${domain}" == "github.com" ]]; then
    download_github "${license}" "${target_license_file}"
  elif [[ "${domain}" =~ gitlab ]]; then
    download_gitlab "${license}" "${target_license_file}"
  else
    >&2 echo "Invalid source: ${domain}. Downloading whole HTML file..."
    download_html "${license}" "${target_license_file}"
  fi
done < <(cat "${components_file}")

>&2 echo "Finished."
