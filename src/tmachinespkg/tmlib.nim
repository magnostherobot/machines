import hashes, tables, strutils, sets

type
  state* = string
  letter* = char
  input* = tuple[state: state, letter: letter]

proc `$`*(input: input): string =
  "(" & $input[0] & " " & $input[1] & ")"

type Direction* = enum
  Dec = -1,
  None = 0,
  Inc = 1

proc `$`*(this: Direction): string =
  case this
  of Dec:
    return "L"
  of None:
    return "S"
  of Inc:
    return "R"

type transition* = tuple[
  newState: state,
  toWrite: letter,
  moveDir: Direction]

proc `$`*(t: transition): string =
  "[" & $t.newState & " " & $t.toWrite & " " & $t.moveDir & "]"

type tape* = Table[int, letter]

proc hash*(this: tape): Hash =
  return ($this).hash()

type ttable* = Table[input, transition]

type configuration* = object
  current_state*: state
  tape*: tape
  position*: int
type config* = configuration

proc hash*(this: config): Hash =
  ## Hashing configurations
  var h: Hash = 0
  h = h !& this.current_state.hash()
  h = h !& this.tape.hash()
  h = h !& this.position.hash()
  return !$h

# Parses a Direction from a string
proc to_direction*(token: string): Direction =
  case token[0]
  of 'R':
    return Inc
  of 'L':
    return Dec
  of 'S':
    return None
  else:
    return None

proc `[]`*(this: configuration, i: int): letter =
  if this.tape.hasKey(i):
    return this.tape[i]
  else:
    return '_'

proc `[]=`*(this: var configuration, i: int, l: letter) =
  this.tape[i] = l

proc get_input*(this: configuration): input =
  return (this.current_state, this[this.position])

proc move*(this: var config, trans: transition): config {.discardable.} =
  this.tape[this.position] = trans.toWrite
  this.position += cast[int](trans.moveDir)
  this.current_state = trans.newState
  return this

# Tape string conversion
proc `$`*(this: configuration): string =
  result = ""
  for i in -30..30:
    if i == 0:
      result &= '['
    result &= $this[this.position + i]
    if i == 0:
      result &= ']'
  result &= " " & $this.current_state

proc insert(this: var tape, input: string, p = 0): tape {.discardable.} =
  for i, c in input:
    this[i + p] = cast[letter](c)
  return this

# Makes a Tape containing this string
proc tapeOf(input: string): tape =
  result = initTable[int, letter]()
  result.insert(input)

proc load*(
  this: var configuration,
  input: string,
  reset: bool = true
): configuration =
  this.tape = tapeOf(input)
  if reset:
    this.position = 0
  return this

## Iterator over every line in a file
proc lineIterator*(f: File): (iterator(): TaintedString {.closure.}) =
  iterator yes(): TaintedString {.closure.} =
    var line: TaintedString
    while readLine(f, line):
      yield line
  return yes

proc make_configuration*(start: state, input: string): configuration =
  return configuration(
    current_state: start,
    tape: tapeOf(input),
    position: 0,
    )
