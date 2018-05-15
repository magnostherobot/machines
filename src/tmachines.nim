import os

import docopt

import tmachinespkg/tm

const tmname {.strdefine.}: string = ""

when tmname.len > 0:
  const tmd = parse(slurp(tmname & ".tm"))
  if paramCount() >= 1:
    echo makeDTM(tmd, paramStr(1)).test(false)
  else:
    echo "please specify a single string argument"
else:
  const doc = slurp("../USAGE.txt")

  let args = docopt(doc)

  let tmd = parse(readFile($args["<machine>"] & ".tm"))
  echo makeDTM(tmd, $args["<input>"]).test(not args["--quiet"])
