#!/bin/sh

function rndm {
  for i in {1..20} ; do
    echo -n $(($RANDOM % 3))
  done
}

k=$1
k=${k:="1"}
until [ "$k" -lt 1 ] ; do
  woa=`rndm`
  echo "$woa`echo $woa | rev` true"
  let k-=1
done
