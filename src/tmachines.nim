import os, strutils

import docopt

from tmachinespkg/tm import nil

const tmname {.strdefine.}: string = ""

when tmname.len > 0:
  const tmd = parse(slurp(tmname))
  if paramCount() >= 1:
    echo makeDTM(tmd, paramStr(1)).test()
  else:
    echo "please specify a single string argument"
else:
  const doc = slurp("../USAGE.txt")

  let args = docopt(doc)
  let file = $args["<machine>"]

  if file.ends_with(".tm") or file.ends_with(".dtm"):
    let tmd = tm.parse(readFile($args["<machine>"]))
    echo tm.test(tm.makeDTM(tmd, $args["<input>"]), not args["--quiet"])
