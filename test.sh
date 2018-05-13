#!/bin/bash
function test {
  diff <(timeout 20s ./$1 $2 || "false") <(echo $3)
}

for file in *.tmt ; do
  name=$(echo $file | cut -f 1 -d '.')
  echo $name
  ./compile "$name"
  while read -r line ; do
    echo $name $line
    test $name $line
  done < "$file"
done
