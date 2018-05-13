#!/bin/sh

function rndm {
  for i in {1..100} ; do
    echo -n $(($RANDOM % 3 ))
  done
}

for i in {1..1000} ; do
  woa=`rndm`
  echo "$woa`echo $woa | rev` true"
done
