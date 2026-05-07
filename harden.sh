#!/bin/bash

# Note the --create-user-config code in tt/project.py passes the code
# through yosis to extect the ports. This wont work with the default tt
# setup because (1) the --create-user-config does not use SLANG and (2)
# the --create-user-config does not incorporate any includes, thus the macro
# is not included.

set -eo pipefail

if [ -z "$IN_NIX_SHELL" ]; then
    echo "Error: you need to be in the project's nix-shell. Run 'nix-shell' first." >&2
    exit 1
fi

source ttsetup/activate

python tt/tt_tool.py --create-user-config
python tt/tt_tool.py --harden
