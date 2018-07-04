import os, strutils

import docopt

from tmachinespkg/tm import nil
from tmachinespkg/ntm import nil

type Machine = enum
  DTM, NTM

proc tm_type_from_cli(value: string): Machine =
  case value
  of "dtm":
    return DTM
  of "ntm":
    return NTM
  else:
    return NTM

proc tm_type_from_filename(filename: string): Machine =
  if filename.ends_with(".dtm"):
    return DTM
  elif filename.ends_with(".ntm"):
    return NTM
  elif filename.ends_with(".tm"):
    return NTM

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

  var m_type: Machine
  if $args["--type"] != "nil":
    m_type = tm_type_from_cli($args["--type"])
  else:
    m_type = tm_type_from_filename(file)

  case m_type:
    of DTM:
      let tmd = tm.parse(readFile($args["<machine>"]))
      echo tm.test(tm.makeDTM(tmd, $args["<input>"]), not args["--quiet"])
    of NTM:
      let tmd = ntm.parse(readFile($args["<machine>"]))
      echo ntm.test(ntm.makeNTM(tmd, $args["<input>"]), not args["--quiet"])
