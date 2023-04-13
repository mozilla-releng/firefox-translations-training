#!/bin/bash
##
# Downloads monolingual data from WMT news crawl
#

set -x
set -euo pipefail

lang=$1
output_prefix=$2
dataset=$3

echo "###### Downloading WMT newscrawl monolingual data"

curl -L "http://data.statmt.org/news-crawl/${lang}/${dataset}.${lang}.shuffled.deduped.gz" | \
    gunzip | zstd -c > "${output_prefix}.zst"

echo "###### Done: Downloading WMT newscrawl monolingual data"
