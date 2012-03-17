# setup Belle II software tools
. `python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $(dirname ${BASH_SOURCE:-$0})`/setup_belle2.sh

# setup the release if the current directory contains a Belle II software release
if [ -f .release ]; then
  setuprel $*
fi
