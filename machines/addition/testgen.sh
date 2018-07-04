#!/bin/bash

function dec2bin {
  echo "obase=2;$1" | bc | tr -d '\n' | rev
}

k=$1
k=${k:="1"}
until [ "$k" -lt 1 ] ; do
  a=$RANDOM
  b=$RANDOM
  c=$(($a + $b))
  echo "`dec2bin $a`#`dec2bin $b`#`dec2bin $c` true"
  let k-=1
done
