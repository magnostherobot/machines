import os

import lib

const tmname {.strdefine.}: string = ""

when tmname.len > 0:
  const tmd = parse(slurp(tmname & ".tm"))
  if paramCount() >= 1:
    echo makeDTM(tmd, paramStr(1)).test(false)
  else:
    echo "please specify a single string argument"
else:
  if paramCount() >= 2:
    let tmd = parse(readFile(paramStr(1) & ".tm"))
    echo makeDTM(tmd, paramStr(2)).test(true)
  else:
    echo "please specify a description and string input"
