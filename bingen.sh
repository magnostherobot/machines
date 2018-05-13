#!/bin/bash

function dec2bin {
  echo "obase=2;$1" | bc | tr -d '\n' | rev
}

for i in {1..1000} ; do
  a=$RANDOM
  b=$RANDOM
  c=$(($a + $b))
  echo "`dec2bin $a`#`dec2bin $b`#`dec2bin $c` true"
done
