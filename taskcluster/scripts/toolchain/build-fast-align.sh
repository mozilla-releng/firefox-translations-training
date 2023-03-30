#!/bin/bash
set -e
set -x

FAST_ALIGN_DIR=$MOZ_FETCHES_DIR/fast_align

cmake $FAST_ALIGN_DIR
make -j$(nproc)

tar --zstd -cf $UPLOAD_DIR/fast-align.tar.zst fast_align atools
