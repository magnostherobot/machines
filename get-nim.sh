#!/bin/sh
# Copied from https://nim-lang.org/install_unix.html:
curl https://nim-lang.org/choosenim/init.sh -sSf | sh

export PATH=$HOME/.nimble/bin:"$PATH"
