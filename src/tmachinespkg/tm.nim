import sets, tables, strutils

import tmlib

type description = object
  initial_state: state
  transitions: ttable
  accepting_states: HashSet[state]

type DTM* = ref object
  acceptingStates*: HashSet[state]
  transitions*: Table[(state, letter), transition]
  configuration*: configuration

proc `[]`*(this: DTM, i: int): letter =
  return this.configuration[i]

proc `[]=`*(this: DTM, i: int, l: letter) =
  this.configuration[i] = l

proc `$`*(this: DTM): string =
  return $this.configuration

proc make_configuration*(desc: description, input: string): configuration =
  return make_configuration(desc.initial_state, input)

proc parse*(description: string): description =
  ## Construct a TM description from an iterator of rules from a .dtm file
  var noStates = -1
  var statesSeen = -1
  var transitions = init_table[input, transition]()
  var acceptingStates = init_set[state]()
  var current_state = cast[state]("")
  var alphabet = false
  for line in description.split_lines:
    # If the line is empty
    if line.len == 0:
      continue
    # If we haven't seen any states yet
    if no_states < 0:
      no_states = line.split_white_space()[1].parseInt()
      states_seen = 0
    # If we're partway through seeing states
    elif no_states > states_seen:
      let split = line.split_white_space()
      # If it's an accepting state
      if split.len == 2:
        acceptingStates.incl(split[0])
      # If it's the first state mentioned
      if statesSeen == 0:
        current_state = (split[0])
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
  return description(
    initial_state: current_state,
    acceptingStates: acceptingStates,
    transitions: transitions
    )

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
    result &= $k.state & " " & $k.letter
    result &= " " & $v.new_state & " " & $v.to_write
    result &= " " & $v.moveDir & "\n"

proc makeDTM*(desc: description, input: string): DTM =
  return DTM(
    configuration: make_configuration(desc, input),
    accepting_states: desc.accepting_states,
    transitions: desc.transitions,
    )

proc test*(this: DTM, verbose: bool = true): bool =
  while true:
    let input = this.configuration.get_input()
    if not this.transitions.has_key(input):
      return false
    let trans = this.transitions[input]
    if trans.new_state in this.accepting_states:
      return true
    this.configuration.move(trans)
    if verbose:
      echo this.configuration
