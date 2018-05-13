# CS3052 Practical 2 - Turing Machines
## Report

## Overview
The task provided for this practical was to implement a Turing machine
emulator in a llnguage of choice, and design Turing machines to solve
specific problems given.

The language chosen to implement the emulator was Nim, a high-level systems
language similar in syntax to Python, but with powerful compile-time
functionality.

## Running the Emulator
To run the emulator, Nim must be installed. A script, `get-nim.sh`, is
provided in the root of the submission. Running it will install Nim in a single
directory (which can easily be removed when done), and add said directory to
the `PATH` environment variable, for this session.

The source provided can be compiled in two separate ways: _interpreter_ and
_crunched_.

### _Interpreter_ Mode
_Interpreter_ is the recommended method for viewing the emulator's
features, and is used as so:
```bash
nim c tm.nim
```
This line produces the executable `tm` as an _interpreter_, used as such:
```bash
./tm DESCRIPTION INPUT
```
where `DESCRIPTION` is the name of a Turing machine description file (less the
`.tm` extension) and `INPUT` the string to test in the described TM.
The emulator will print, for each transition: the tape contents around the
selected cell; the name of the current state; and the number of iterations
since initialisation. If the emulation halts, `true` is printed if it halted
in an accepting state, and `false` is printed otherwise.

### _Crunched_ Mode
_Crunched_ mode reads in a selected TM description file and creates an
executable binary file capable of checking input strings for the described TM.

Crunching is done like so:
```bash
nim c -d:tmname=DESCRIPTION tm.nim
```
Alternatively, a utility script `compile` has been included in the submission.
The following line crunches a TM description file `woa.tm` and produces
executable `woa`:
```bash
./compile woa
```
Using the cruched executable `woa` would be done like so:
```bash
./woa INPUT
```
Crunched executables only output a `true`/`false`, and are
designed with testing and long-running emulation in mind.

### Testing
A bash script `test.sh` is provided. It searches the current working directory
for files ending in `.tmt`, which it assumes is a list of test input strings
followed by the expected `true`/`false` output of the TM associated by name.
Tests that take a long time are assumed to be non-halting, and so are terminated
prematurely with an assumption that the input is rejected.

More bash scripts are used to generate passing tests for the provided TMs:
`bingen.sh` and `palgen.sh`. Running these will print 1000 randomly-generated
validation tests to the console. More tests, such as exceptional contexts, were
tested manually.

### enihcaM gniruT
A second program, `mt.nim`, is provided. It can read in the validation tests,
and create a TM that passes only on the input strings provided as `true` in the
test files. It can then output the description of this TM (if passed no
arguments), or run it against an input string. This program takes in the
validation test file at compile-time, like so:
```bash
nim c -d:tmname=VALIDATION mt.nim
```
where `VALIDATION` is the name of the validation test file to be crunched, less
the file extension.

## Emulator Design
The emulator written in Nim takes any valid TM description file, as specified in
the project specification, and creates an internal representation of the
described TM in memory.

Originally, the approach was much more object-oriented, with `State`s having
their own internal transition-table. This was found to be quite slow,
and a rearrangement into `string` representations of states proved to speed
processing dramatically.

Improving on performance still, the emulator was rewritten a second time to
be able to 'crunch' TM descriptions into the binary itself. This was the
largest increase to speed - this can be accredited to Nim's incorporation of C
compilers (in the case of the lab machines, `gcc`).

Given more time, the next step would be to measure this performance change: in
particular, looking for any changes in time complexity produced by the
compiler/optimiser.

`mt.nim` was written with the idea of comparing its running time to that of
`tm.nim`: the thinking was that `mt` would produce the fastest possible
TM that sees all of the input, and accepts the strings found in the validation
tests. Given more time, `tm` and `mt` could have their complexities compared
for a number of languages.

## Complexity
### Palindrome
The palindrome checker compares _n_/2 pairs of characters, and in doing so
walks across the input and back again. However, each comparision reduces the
length of the input by 2, meaning the number of transitions must be
approximately (_n_)+(_n_-1)+(_n_-2)+...+1 = _n_(_n_+1)/2. This gives an
approximate complexity of _n_-squared.

### Binary
There are a lot of complications that can arise in this algorithm, such as
differing lengths of numbers, but again this algorithm relies on walking
across the input and back. It only walks to to first remaining digit of the last
number (a fraction of _n_ less than 1) and only walks back to the first
remaining digit of the first number (also less than _n_). This cycle is
repeated once for every digit that exists in the longer of the first two numbers
whose length depends on n. The number of required steps then is roughly
(_an_+_bn_)._cn_, so the complexity of this algorithm approximately is
_n_-squared.

## Conclusion
I am disappointed that I got so little done for this practical: I throughly
enjoy puzzles similar to that of designing Turing machines, and also enjoy
thinking in the mentality of simple machines. Given more time, I would have
produced experiments and results, and investigated the optimisations provided
by compiling through `nim` and `gcc`.
