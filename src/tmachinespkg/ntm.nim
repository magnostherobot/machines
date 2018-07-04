import sets, tables, strutils

import tmlib

type ttable = Table[input, HashSet[transition]]

type description = object
  initial_state: state
  transitions: ttable
  accepting_states: HashSet[state]

type NTM* = ref object
  acceptingStates*: HashSet[state]
  transitions*: ttable
  configurations*: HashSet[configuration]

proc print_configurations*(this: NTM): string =
  result = ""
  for config in this.configurations:
    result &= $config & "\n"
  result &= "\n"

proc move_copy(this: config, trans: transition): config =
  result = this
  result.move(trans)

proc parse*(description: string): description =
  ## Construct an NTM description from an iterator of rules from a .ntm file
  var noStates = -1
  var statesSeen = -1
  var transitions = init_table[input, HashSet[transition]]()
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
        input = (s[0], s[1][0])
        outs = s[2]
        outl = s[3][0]
        outd = to_direction(s[4])
      let transition = (
        newState: outs,
        toWrite: outl,
        moveDir: outd,
        )
      if not transitions.has_key(input):
        transitions[input] = init_set[transition]()
      transitions[input].incl transition
    # Next line
  return description(
    initial_state: current_state,
    acceptingStates: acceptingStates,
    transitions: transitions
    )

proc make_configuration*(desc: description, input: string): configuration =
  return make_configuration(desc.initial_state, input)

proc makeNTM*(desc: description, input: string): NTM =
  var configs = init_set[configuration]()
  configs.incl(make_configuration(desc, input))
  return NTM(
    configurations: configs,
    accepting_states: desc.accepting_states,
    transitions: desc.transitions,
    )

proc test*(this: NTM, verbose: bool = true): bool =
  while this.configurations.card != 0:
    var new_configs = init_set[config]()
    for config in this.configurations:
      let input = config.get_input()
      if this.transitions.has_key(input):
        for trans in this.transitions[input]:
          if trans.new_state in this.accepting_states:
            return true
          new_configs.incl(config.move_copy(trans))
    this.configurations = new_configs
    if verbose:
      echo this.print_configurations()
  return false
