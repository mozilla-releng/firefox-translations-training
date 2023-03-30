#!/bin/bash
set -e
set -x

export MARIAN_DIR=$MOZ_FETCHES_DIR/marian-source
export CUDA_DIR=$MOZ_FETCHES_DIR/cuda

# TODO: consider not calling out to this since it's such a simple script...
bash $VCS_PATH/pipeline/setup/compile-marian.sh "${MARIAN_DIR}/build" "$(nproc)"

tar --zstd -cf $UPLOAD_DIR/marian.tar.zst \
  "${MARIAN_DIR}/build/marian"
  "${MARIAN_DIR}/build/marian-decoder"
  "${MARIAN_DIR}/build/marian-scorer"
  "${MARIAN_DIR}/build/marian-conv"
  "${MARIAN_DIR}/build/spm_train"
  "${MARIAN_DIR}/build/spm_encode"
  "${MARIAN_DIR}/build/spm_export_vocab"
