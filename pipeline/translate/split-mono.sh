#!/bin/bash
##
# Splits and deduplicates a monolingual dataset
#


set -x
set -euo pipefail

test -v BIN

mono_path=$1
output_dir=$2
length=$3
compress_output=${4:-false}

COMPRESSION_CMD="${COMPRESSION_CMD:-pigz}"
ARTIFACT_EXT="${ARTIFACT_EXT:-gz}"

if [ "${compress_output}" = "" ]; then
  compress_output="false"
fi

mkdir -p "${output_dir}"
${COMPRESSION_CMD} -dc "${mono_path}" | ${BIN}/dedupe | split -d -l ${length} - "${output_dir}/file."

if [ "${compress_output}" = "true" ]; then
  cd "${output_dir}"
  tar -cf - * | $COMPRESSION_CMD > "${output_dir}/split-files.tar.${ARTIFACT_EXT}"
fi
