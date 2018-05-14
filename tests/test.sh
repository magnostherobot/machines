#!/bin/bash
function test {
  diff <(timeout 20s ./$1 $2 || "false") <(echo $3)
}

for file in `ls -1 $1` ; do
  if [ -e "$1/$file/testgen.sh" ] ; then
    "$1/$file/testgen.sh" | while read line ; do
      echo "./tmachines $1/$file/$file" $line
      test "./tmachines $1/$file/$file" $line
    done
  fi
done
