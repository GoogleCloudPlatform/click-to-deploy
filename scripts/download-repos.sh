#!/bin/bash

declare -r repositories_list="$1"

function print_usage() {
  >&2 echo "Iterates over a git repository list and git clones them to the current directory"
  >&2 echo "Usage:"
  >&2 echo "./download-repos.sh repos.txt"
}

# Validate parameters
if [[ "$#" -eq 1 ]]; then
  if [[ ! -f "${repositories_list}" ]]; then
    print_usage
    exit 1
  fi
else
  print_usage
  exit 1
fi

# Download the repositories
for repo in $(cat "${repositories_list}"); do
  >&2 echo "Downloading ${repo}..."
  git clone "${repo}" -q
done

echo "Finished!"
