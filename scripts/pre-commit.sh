#!/bin/bash

for d in ../data_bags/*/ ; do
  for f in $d* ; do
    if grep -q 'encrypted_data' $f; then
      echo "$f is encrypted [PASS]\n"
    else
      echo "$f contains non-encrypted data, please run the lock.sh script before committing again [FAIL]\n"
      exit 1
    fi
  done
done