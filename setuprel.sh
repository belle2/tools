# check number of arguments
if [ $# -gt 1 -o "$1" = "-h" ]; then
  echo "Usage: setuprel [release]" 1>&2
  return
fi

# if the release version is given as argument take it from there
if [ $# -gt 0 ]; then
  RELEASE=$1

  # check whether it matches the release in the current directory
  if [ -f .release ]; then
    LOCAL_RELEASE=`cat .release`
    if [ "${LOCAL_RELEASE}" != "${RELEASE}" ]; then
      echo "Warning: The given release (${RELEASE}) differs from the one in the current directory (${LOCAL_RELEASE}). Ignoring the local version." 1>&2
      unset LOCAL_RELEASE
    fi
  fi
else

  # check whether we are in a release directory and take the release version from there
  if [ ! -f .release ]; then
    echo "Not in a release directory." 1>&2
    unset LOCAL_RELEASE
    return
  fi
  LOCAL_RELEASE=`cat .release`
  RELEASE=${LOCAL_RELEASE}
fi

# define architecture and build option
export BELLE2_ARCH=`uname`_`uname -m`
export BELLE2_OPTION=${BELLE2_OPTION=debug}
export BELLE2_SUBDIR=${BELLE2_ARCH}/${BELLE2_OPTION}

# check whether a central release exists
DIR=${VO_BELLE2_SW_DIR}/releases/${RELEASE}
if [ "${RELEASE}" != "head" ]; then
  if [ ! -d ${DIR} ]; then
    echo "Warning: No central release ${RELEASE} found."
    unset RELEASE

  else
    # add release directory to path, library path, and python path
    if [ -n "${PATH}" ]; then
      export PATH=${DIR}/bin/${BELLE2_SUBDIR}:${PATH}
    else
      export PATH=${DIR}/bin/${BELLE2_SUBDIR}
    fi
    if [ -n "${LD_LIBRARY_PATH}" ]; then
      export LD_LIBRARY_PATH=${DIR}/lib/${BELLE2_SUBDIR}:${LD_LIBRARY_PATH}
    else
      export LD_LIBRARY_PATH=${DIR}/lib/${BELLE2_SUBDIR}
    fi
    if [ -n "${PYTHONPATH}" ]; then
      export PYTHONPATH=${DIR}/lib/${BELLE2_SUBDIR}:${PYTHONPATH}
    else
      export PYTHONPATH=${DIR}/lib/${BELLE2_SUBDIR}
    fi

    # add externals directory to path and library path
    export PATH=${DIR}/externals/bin/${BELLE2_SUBDIR}:${PATH}
    export LD_LIBRARY_PATH=${DIR}/externals/lib/${BELLE2_SUBDIR}:${LD_LIBRARY_PATH}

    # setup geant4 environment
    . ${DIR}/externals/geant4/env.sh > /dev/null

    # set ROOTSYS
    export ROOTSYS=${DIR}/externals/root

    # set environment variables
    export BELLE2_RELEASE_DIR=${DIR}
  fi
fi

# take care of local release
DIR=$PWD
if [ -n "${LOCAL_RELEASE}" ]; then
  RELEASE=${LOCAL_RELEASE}

  # add release directory to path, library path, and python path
  if [ -n "${PATH}" ]; then
    export PATH=${DIR}/bin/${BELLE2_SUBDIR}:${PATH}
  else
    export PATH=${DIR}/bin/${BELLE2_SUBDIR}
  fi
  if [ -n "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH=${DIR}/lib/${BELLE2_SUBDIR}:${LD_LIBRARY_PATH}
  else
    export LD_LIBRARY_PATH=${DIR}/lib/${BELLE2_SUBDIR}
  fi
  if [ -n "${PYTHONPATH}" ]; then
    export PYTHONPATH=${DIR}/lib/${BELLE2_SUBDIR}:${PYTHONPATH}
  else
    export PYTHONPATH=${DIR}/lib/${BELLE2_SUBDIR}
  fi

  # add externals directory to path and library path
  export PATH=${DIR}/externals/bin/${BELLE2_SUBDIR}:${PATH}
  export LD_LIBRARY_PATH=${DIR}/externals/lib/${BELLE2_SUBDIR}:${LD_LIBRARY_PATH}

  # setup geant4 environment
  if [ -f ${DIR}/externals/geant4/env.sh ]; then
    . ${DIR}/externals/geant4/env.sh > /dev/null
  fi

  # set ROOTSYS
  if [ -d ${DIR}/externals/root ]; then
    export ROOTSYS=${DIR}/externals/root
  fi

  # set environment variables
  export BELLE2_LOCAL_DIR=${DIR}
fi

# set environment variables
if [ -n "${RELEASE}" ]; then
  export BELLE2_RELEASE=${RELEASE}
fi

# clean up
unset DIR
unset LOCAL_RELEASE
unset RELEASE
