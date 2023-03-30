#!/bin/bash
set -e
set -x

PIGZ_DIR=$MOZ_FETCHES_DIR/pigz-source

cd $PIGZ_DIR
make -j$(nproc)

cp pigz $UPLOAD_DIR
