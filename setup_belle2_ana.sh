# setup Belle II software tools
. `python -c 'from __future__ import print_function; import os,sys;print(os.path.realpath(sys.argv[1]))' $(dirname ${BASH_SOURCE:-$0})`/setup_belle2.sh

# setup the analysis if the current directory contains Belle II analysis code
if [ -f .analysis ]; then
  setupana $*
fi
