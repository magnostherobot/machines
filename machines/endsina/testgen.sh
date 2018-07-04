#!/bin/bash

k=$1
k=${k:="1"}
until [ "$k" -lt 1 ] ; do
  o=""
  for i in `seq 1 20` ; do
    if [ $(($RANDOM%2)) -lt 1 ] ; then
      o="${o}a"
      b="true"
    else
      o="${o}b"
      b="false"
    fi
  done
  echo "$o $b"
  let k-=1
done
