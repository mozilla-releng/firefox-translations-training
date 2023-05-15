#!/bin/bash
set -e
set -x

EXTRACT_LEX_DIR=$MOZ_FETCHES_DIR/extract-lex

build_dir=$(mktemp -d)
cd $build_dir
cmake $EXTRACT_LEX_DIR
make -j$(nproc)

chmod +x $build_dir/extract_lex
tar --zstd -cf $UPLOAD_DIR/extract_lex.tar.zst $build_dir/extract_lex
