## Running the Emulator
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
The emulator written in Nim takes any valid TM description file and creates an
internal representation of the described TM in memory.
