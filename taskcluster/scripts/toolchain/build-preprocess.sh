#!/bin/bash
set -e
set -x

PREPROCESS_DIR=$MOZ_FETCHES_DIR/preprocess

cmake $PREPROCESS_DIR -DBUILD_TYPE=Release
make -j$(nproc)

cp dedupe $UPLOAD_DIR
