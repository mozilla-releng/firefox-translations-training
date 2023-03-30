#!/bin/bash
set -e
set -x

EXTRACT_LEX_DIR=$MOZ_FETCHES_DIR/extract-lex

cmake $EXTRACT_LEX_DIR
make -j$(nproc)

cp extract_lex $UPLOAD_DIR
