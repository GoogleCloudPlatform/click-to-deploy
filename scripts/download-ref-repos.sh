#!/bin/bash

declare -r ref_repos="$1"
declare -r target_dir="$2"

function print_usage() {
  >&2 echo "Create references for external repositories"
  >&2 echo "Usage:"
  >&2 echo "./download-ref-repos.sh ref_repos.txt /usr/src"
}

# Validate parameters
if [[ "$#" -eq 2 ]]; then
  if [[ ! -f "${ref_repos}" ]]; then
    print_usage
    exit 1
  fi
else
  print_usage
  exit 1
fi

>&2 echo "Creating references for the remote source-code..."

for repo in $(cat "${ref_repos}"); do
  declare repo_name="$(echo "${repo}" |  awk -F / '{ print $NF }')"
  >&2 echo "Source-code available at: ${repo}" > "${target_dir}/${repo_name}_SOURCE"
done

echo "Finished."
