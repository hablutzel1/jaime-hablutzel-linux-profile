#!/bin/bash

# TODO instead of simply replacing the local .bash_aliases, maybe it would be better to merge against it.
cp `dirname "$0"`/.bash_aliases ~ && echo ".bash_aliases copied"
