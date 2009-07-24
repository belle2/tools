# check whether we are in a release directory
if [ ! -f .release ]; then
  echo "Not in a release directory." 1>&2
  return
fi

# add release directory to path and library path
DIR=$PWD
ARCH=`uname`_`uname -m`
if [ -n "${PATH}" ]; then
  export PATH=${DIR}/bin/${ARCH}:${PATH}
else
  export PATH=${DIR}/bin/${ARCH}
fi
if [ -n "${LD_LIBRARY_PATH}" ]; then
  export LD_LIBRARY_PATH=${DIR}/lib/${ARCH}:${LD_LIBRARY_PATH}
else
  export LD_LIBRARY_PATH=${DIR}/lib/${ARCH}
fi

# setup root
export ROOTSYS=${DIR}/externals/root
export PATH=${ROOTSYS}/bin:${PATH}
export LD_LIBRARY_PATH=${ROOTSYS}/lib:${LD_LIBRARY_PATH}

unset DIR
unset ARCH
