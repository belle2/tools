# setup Belle II software tools
. $(readlink -f "`dirname ${BASH_SOURCE:-$0}`")/setup_belle2.sh

# setup the release if the current directory contains a Belle II software release
if [ -f .release ]; then
  setuprel $*
fi
