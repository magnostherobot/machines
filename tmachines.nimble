# Package

version       = "0.1.0"
author        = "Tom Harley"
description   = "Turing Machine emulator"
license       = "MIT"
srcDir        = "src"
bin           = @["tmachines"]

# Dependencies

requires "nim >= 0.18.0", "docopt"

# Scripts

task test, "Runs the test script":
  exec "./tests/test.sh ./machines"
