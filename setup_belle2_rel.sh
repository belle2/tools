# setup Belle II software tools
. `python -c 'from __future__ import print_function; import os,sys;print(os.path.realpath(sys.argv[1]))' $(dirname ${BASH_SOURCE:-$0})`/setup_belle2.sh

# setup the release if the current directory contains a Belle II software release
if [ -f .release ]; then
  setuprel $*
fi
