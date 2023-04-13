#!/bin/bash
##
# Downloads corpus using sacrebleu
#

set -x
set -euo pipefail

echo "###### Downloading sacrebleu corpus"

src=$1
trg=$2
output_prefix=$3
dataset=$4

sacrebleu -t "${dataset}" -l "${src}-${trg}" --echo src | zstd -c > "${output_prefix}.${src}.zst"
sacrebleu -t "${dataset}" -l "${src}-${trg}" --echo ref | zstd -c > "${output_prefix}.${trg}.zst"

echo "###### Done: Downloading sacrebleu corpus"
