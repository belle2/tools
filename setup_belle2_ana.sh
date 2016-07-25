# setup Belle II software tools
. `python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $(dirname ${BASH_SOURCE:-$0})`/setup_belle2.sh

# setup the analysis if the current directory contains Belle II analysis code
if [ -f .analysis ]; then
  setupana $*
fi
