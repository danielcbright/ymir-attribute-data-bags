#!/bin/bash

for d in ../data_bags/*/ ; do
  dirname="${d%/}"
  dirname="${dirname##*/}"
  for f in $d* ; do
    filename="${f%/}"
    filename="${filename##*/}"
    filename=$(echo "$filename" | cut -f 1 -d '.')
    if echo $f | grep -q 'open.json'; then
      itemname="${filename/-open/}"
      knife data bag create $dirname --local-mode
      knife data bag from file $dirname $f --local-mode --secret-file ../secrets/encryption_key
      knife data bag show $dirname $itemname --local-mode -F json > `echo "${f/-open/}"`
      rm $f
    fi
  done
done