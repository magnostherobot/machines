import hashes, tables, strutils, sets

type
  state* = string
  letter* = char
  input* = tuple[state: state, letter: letter]

proc `$`(input: input): string =
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

proc `$`(t: transition): string =
  "[" & $t.newState & " " & $t.toWrite & " " & $t.moveDir & "]"

type tape* = Table[int, letter]
type ttable* = Table[input, transition]

type DTM* = ref object
  currentState*: state
  acceptingStates*: HashSet[state]
  tape*: tape
  position*: int
  transitions*: Table[(state, letter), transition]

type description* = tuple [
  currentState: state,
  acceptingStates: HashSet[state],
  transitions: Table[input, transition]
  ]

# Parses a Direction from a string
proc toDirection(token: string): Direction =
  case token[0]
  of 'R':
    return Inc
  of 'L':
    return Dec
  of 'S':
    return None
  else:
    return None

proc `[]`(this: DTM, i: int): letter =
  if this.tape.hasKey(i):
    return this.tape[i]
  else:
    return '_'

proc `[]=`(this: DTM, i: int, l: letter) =
  this.tape[i] = l

# Tape string conversion
proc `$`(this: DTM): string =
  result = ""
  for i in -150..150:
    if i == 0:
      result &= '['
    result &= $this[this.position + i]
    if i == 0:
      result &= ']'

proc write(this: DTM, c: letter): DTM {.discardable.} =
  this[this.position] = c
  return this

## Write to and move DTM
proc move(this: DTM, move: transition): DTM {.discardable.} =
  # Change state:
  this.currentState = move.newState
  # Write to tape:
  this[this.position] = move.toWrite
  # Move position on tape:
  this.position += cast[int](move.moveDir)
  return this

proc insert(this: var tape, input: string, p = 0): tape {.discardable.} =
  for i, c in input:
    this[i + p] = cast[letter](c)
  return this

# Makes a Tape containing this string
proc tapeOf(input: string): tape =
  result = initTable[int, letter]()
  result.insert(input)

## Fits this DTM with a Tape containing this string
proc load(tm: DTM, input: string): DTM =
  return DTM(
    tape: tapeOf(input),
    acceptingStates: tm.acceptingStates,
    currentState: tm.currentState,
    transitions: tm.transitions
    )

## Fits this DTM with a Tape containing this string
proc `<<`(tm: DTM, input: string): DTM =
  return tm.load(input)

## Iterator over every line in a file
proc lineIterator(f: File): (iterator(): TaintedString {.closure.}) =
  iterator yes(): TaintedString {.closure.} =
    var line: TaintedString
    while readLine(f, line):
      yield line
  return yes

iterator characters(filename: string): char =
  for line in lines filename:
    for letter in line:
      yield letter

## Construct a DTM from an iterator of rules from a description file
proc parse*(description: string): description =
  var noStates = -1
  var statesSeen = -1
  var transitions = initTable[input, transition]()
  var acceptingStates = initSet[state]()
  var currentState = cast[state]("")
  var alphabet = false
  for line in description.splitLines:
    # If the line is empty
    if line.len == 0:
      continue
    # If we haven't seen any states yet
    if noStates < 0:
      noStates = line.splitWhiteSpace()[1].parseInt()
      statesSeen = 0
    # If we're partway through seeing states
    elif noStates > statesSeen:
      let split = line.splitWhiteSpace()
      # If it's an accepting state
      if split.len == 2:
        acceptingStates.incl(split[0])
      # If it's the first state mentioned
      if statesSeen == 0:
        currentState = (split[0])
      statesSeen += 1
    # If we haven't seen the alphabet yet
    elif not alphabet:
      alphabet = true
    # If we're past all that and are at transitions
    else:
      let s = line.splitWhiteSpace()
      let
        ins = s[0]
        inl = s[1][0]
        outs = s[2]
        outl = s[3][0]
        outd = toDirection(s[4])
      let transition = (
        newState: outs,
        toWrite: outl,
        moveDir: outd)
      transitions[(ins, inl)] = transition
    # Next line
  return (
    currentState: currentState,
    acceptingStates: acceptingStates,
    transitions: transitions
    )

proc makeDTM*(desc: description, input: string): DTM =
  return DTM(
    currentState: desc[0],
    acceptingStates: desc[1],
    transitions: desc.transitions,
    tape: tapeOf(input))

proc toFile*(desc: description): string =
  var states = initSet[state]()
  var alphabet: set[letter] = {}
  for k, v in desc.transitions:
    states.incl k.state
    states.incl v.newState
    alphabet.incl k.letter
    alphabet.incl v.toWrite
  result = "states " & $states.len & "\n"
  for v in states:
    result &= $v & "\n"
  result &= "alphabet " & $alphabet.card()
  for v in alphabet:
    result &= " " & $v
  result &= "\n"
  for k, v in desc.transitions:
    result &= $k.state & " " & $k.letter & " " & $v.newState & " " & $v.toWrite
    result &= " " & $v.moveDir & "\n"

## Step through DTM emulation until it would halt
proc test*(tm: DTM, speak: bool): bool =
  var m: transition
  var i = 0
  try:
    while true:
      i += 1
      if speak:
        echo(tm, " ", tm.currentState, " ", i)
      m = tm.transitions[(tm.currentState, tm[tm.position])]
      tm.move(m)
  except KeyError:
    return tm.acceptingStates.contains(tm.currentState)

## Does this DTM accept this string as input?
proc `<<?`*(tm: DTM, input: string): bool =
  return tm.load(input).test(false)
