#!/bin/bash
function test {
  diff <(timeout 20s $1 || "false") <(echo $2)
}

for file in `ls -1 $1` ; do
  if [ -e "$1/$file/testgen.sh" ] ; then
    "$1/$file/testgen.sh" 50 | while read line ; do
      split=($line)
      echo ./tmachines $1/$file/$file $line
      test "./tmachines --quiet $1/$file/$file ${split[0]}" ${split[1]}
    done
  fi
done
