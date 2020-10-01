#!/bin/bash

for d in ../data_bags/*/ ; do
  dirname="${d%/}"
  dirname="${dirname##*/}"
  for f in $d* ; do
    filename="${f%/}"
    filename="${filename##*/}"
    filename=$(echo "$filename" | cut -f 1 -d '.')
    if echo $filename | grep -q -v 'open'; then
      knife data bag create $dirname --local-mode
      knife data bag from file $dirname $f --local-mode
      knife data bag show $dirname $filename --local-mode --secret-file ../secrets/encryption_key -F json > `echo "${f/.json/-open.json}"`
    fi
  done
done