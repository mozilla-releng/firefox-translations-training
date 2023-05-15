#!/bin/bash
set -e
set -x

PREPROCESS_DIR=$MOZ_FETCHES_DIR/preprocess

build_dir=$(mktemp -d)
cd $build_dir
cmake $PREPROCESS_DIR -DBUILD_TYPE=Release
make -j$(nproc)

chmod +x $build_dir/bin/dedupe
tar --zstd -cf $UPLOAD_DIR/dedupe.tar.zst $build_dir/bin/dedupe
