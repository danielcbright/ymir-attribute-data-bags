#!/bin/bash
function _usage {
  echo ""
  echo "USAGE: "
  echo "  dbag-ops.sh [-u | -l] [-s <relative_path_to_secret_file>]"
  echo ""
  echo "OPTIONS:"
  echo "  [-u | -l]   (u)nlock or (l)ock all data bags in this repo"
  echo "  -d          specify data bag name, default is *"
  echo "  -s          specify secret file path/name e.g. '../secrets/my_secret_key'"
  echo ""
  echo "EXAMPLE:"
  echo "    getopts.sh -u -s ../secrets/my_secret_key"
  echo ""
  exit $E_OPTERROR
}

lock='false'
unlock='false'
dbag='*'

while getopts d:s:ul-: opt ;
do
  case $opt in
    s) secretfile=$OPTARG;;
    u) unlock='true';;
    l) lock='true';;
    d) dbag=$OPTARG;;
    \?) bad=1 ;;
  esac
done

if [ $unlock = 'true' ] && [ $lock = 'true' ]; then
  echo "!!You cannot set both lock and unlock, you must choose one or the other!!"
  _usage
fi

if [ -f "$secretfile" ]; then
  if [ $lock = 'true' ] && [ $unlock = 'false' ]; then
    for d in ../data_bags/$dbag/ ; do
      dirname="${d%/}"
      dirname="${dirname##*/}"
      for f in $d* ; do
        filename="${f%/}"
        filename="${filename##*/}"
        filename=$(echo "$filename" | cut -f 1 -d '.')
        echo "$dirname / $filename"
        if echo $f | grep -q 'open.json'; then
          itemname="${filename/-open/}"
          knife data bag create $dirname --local-mode
          knife data bag from file $dirname $f --local-mode --secret-file $secretfile
          knife data bag show $dirname $itemname --local-mode -F json > `echo "${f/-open/}"`
          rm $f
        fi
      done
    done
  elif [ $unlock = 'true' ] && [ $lock = 'false' ]; then
    for d in ../data_bags/$dbag/ ; do
      dirname="${d%/}"
      dirname="${dirname##*/}"
      for f in $d* ; do
        filename="${f%/}"
        filename="${filename##*/}"
        filename=$(echo "$filename" | cut -f 1 -d '.')
        echo "$dirname / $filename"
        if echo $filename | grep -q -v 'open'; then
          knife data bag create $dirname --local-mode
          knife data bag from file $dirname $f --local-mode
          knife data bag show $dirname $filename --local-mode --secret-file $secretfile -F json > `echo "${f/.json/-open.json}"`
        fi
      done
    done
  fi
else
  echo "!!secret file '$secretfile' does not exist!!"
  _usage
fi

if [[ $bad -eq 1 ]] ; then
    _usage
fi