#!/bin/bash

set -x
set -euo pipefail

type=$1
chunks=$2
output_dir=$3
length=$4
lang_args=( "${@:5}" )

pushd `dirname $0`/../../.. &>/dev/null
VCS_ROOT=$(pwd)
popd &>/dev/null

if [ "${type}" = "mono" ]; then
  ${VCS_ROOT}/pipeline/translate/split-mono.sh "${lang_args[@]}" "${output_dir}" "${length}"
elif [ "${type}" = "corpus" ]; then
  ${VCS_ROOT}/pipeline/translate/split-corpus.sh "${lang_args[@]}" "${output_dir}" "${length}"
else
  echo "Unknown split type: ${type}"
  exit 1
fi

# Taskcluster requires a consistent number of chunks; split the resulting files
# evenly into the requested number of chunks, creating empty archives if there's
# not enough files to go around.
cd "${output_dir}"
ls file* | grep -v "\.ref" | sort > src-files.txt
ls file* | grep "\.ref" | sort > ref-files.txt
for i in $(seq 1 ${chunks} | tr '\n' ' '); do
  src_files=$(split -n l/${i}/${chunks} src-files.txt | tr '\n' ' ')
  ref_files=$(split -n l/${i}/${chunks} ref-files.txt | tr '\n' ' ')
  if [ "${src_files}" = "" ]; then
    touch "src-file.${i}"
  else
    cat ${src_files} > "src-file.${i}"
  fi
  zstd --rm "src-file.${i}"
  if [ "${ref_files}" = "" ]; then
    touch "ref-file.${i}"
  else
    cat ${ref_files} > "ref-file.${i}"
  fi
  zstd --rm "ref-file.${i}"
done

rm file* src-files.txt ref-files.txt
