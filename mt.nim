import uuid
import sets
import os
import tables
import strutils

import lib

proc accept(
  this: var ttable,
  initialState: state,
  input: string,
  u: string
): state {.discardable.} =
  var cs = initialState
  for c in input:
    if not this.hasKey((cs, c)):
      this[(cs, c)] = (u, '_', Inc)
    cs = this[(cs, c)].newState
  return cs

proc esarp(content: string): description =
  var tt = initTable[input, transition]()
  var ac = initSet[state]()
  var i = 0
  const initialState = "S"
  for line in content.splitLines:
    if line.len <= 0: continue
    let split = line.split(' ')
    if split[1].parseBool():
      ac.incl tt.accept(initialState, split[0], $i)
    i += 1
  return (initialState, ac, tt)

const tmname {.strdefine.}: string = "addition"
const desc = esarp(slurp(tmname & ".tmt"))

if paramCount() >= 1:
  echo makeDTM(desc, paramStr(1)).test(true)
else:
  echo desc.toFile()
