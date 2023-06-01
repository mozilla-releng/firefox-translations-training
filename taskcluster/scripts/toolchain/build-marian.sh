#!/bin/bash
set -e
set -x

export MARIAN_DIR=$MOZ_FETCHES_DIR/marian-source
export CUDA_DIR=$MOZ_FETCHES_DIR/cuda-toolkit

# Ugly hack to workaround the fact that browsermt Marian doesn't have proper CUDA 12.0 support
# in its build system.
sed -i -e 's/"Compile GPU version with SM35 support" ON/"Compile GPU version with SM35 support" OFF/' $MARIAN_DIR/CMakeLists.txt

# TODO: consider not calling out to this since it's such a simple script...
bash $VCS_PATH/pipeline/setup/compile-marian.sh "${MARIAN_DIR}/build" "$(nproc)"

cd $MARIAN_DIR/build
tar --zstd -cf $UPLOAD_DIR/marian.tar.zst \
  "marian" \
  "marian-decoder" \
  "marian-scorer" \
  "marian-conv" \
  "spm_train" \
  "spm_encode" \
  "spm_export_vocab"
