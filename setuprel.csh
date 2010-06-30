# check number of arguments
if ( $# > 1 || "$1" == "-h" ) then
  echo "Usage: setuprel [release]"
  exit
endif

# if the release version is given as argument take it from there
if ( $# > 0 ) then
  set RELEASE=$1

  # check whether it matches the release in the current directory
  if ( -f .release ) then
    set LOCAL_RELEASE=`cat .release`
    if ( "${LOCAL_RELEASE}" != "${RELEASE}" ) then
      echo "Warning: The given release (${RELEASE}) differs from the one in the current directory (${LOCAL_RELEASE}). Ignoring the local version."
      unset LOCAL_RELEASE
    endif
  endif
else

  # check whether we are in a release directory and take the release version from there
  if ( ! -f .release ) then
    echo "Not in a release directory."
    unset LOCAL_RELEASE
    exit
  endif
  set LOCAL_RELEASE=`cat .release`
  set RELEASE=${LOCAL_RELEASE}
endif

# define architecture and build option
setenv BELLE2_ARCH `uname`_`uname -m`
if ( ! ${?BELLE2_OPTION} ) then
    setenv BELLE2_OPTION debug
endif
setenv BELLE2_SUBDIR ${BELLE2_ARCH}/${BELLE2_OPTION}

# check whether a central release exists
set DIR=${VO_BELLE2_SW_DIR}/releases/${RELEASE}
if ( "${RELEASE}" != "head" ) then
  if ( ! -d ${DIR} ) then
    echo "Warning: No central release ${RELEASE} found."
    unset RELEASE

  else
    # add release directory to path, library path, and python path
    if ( ${?PATH} ) then
      setenv PATH ${DIR}/bin/${BELLE2_SUBDIR}:${PATH}
    else
      setenv PATH ${DIR}/bin/${BELLE2_SUBDIR}
    endif
    if ( ${?LD_LIBRARY_PATH} ) then
      setenv LD_LIBRARY_PATH ${DIR}/lib/${BELLE2_SUBDIR}:${LD_LIBRARY_PATH}
    else
      setenv LD_LIBRARY_PATH ${DIR}/lib/${BELLE2_SUBDIR}
    endif
    if ( ${?PYTHONPATH} ) then
      setenv PYTHONPATH ${DIR}/lib/${BELLE2_SUBDIR}:${PYTHONPATH}
    else
      setenv PYTHONPATH ${DIR}/lib/${BELLE2_SUBDIR}
    endif

    # add externals directory to path and library path
    setenv PATH ${DIR}/externals/bin/${BELLE2_SUBDIR}:${PATH}
    setenv LD_LIBRARY_PATH ${DIR}/externals/lib/${BELLE2_SUBDIR}:${LD_LIBRARY_PATH}

    # setup geant4 environment
    source ${DIR}/externals/geant4/env.csh > /dev/null

    # set ROOTSYS
    setenv ROOTSYS ${DIR}/externals/root

    # set environment variables
    setenv BELLE2_RELEASE_DIR ${DIR}
  endif
endif

# take care of local release
set DIR=$PWD
if ( ${?LOCAL_RELEASE} ) then
  set RELEASE=${LOCAL_RELEASE}

  # add release directory to path, library path, and python path
  if ( ${?PATH} ) then
    setenv PATH ${DIR}/bin/${BELLE2_SUBDIR}:${PATH}
  else
    setenv PATH ${DIR}/bin/${BELLE2_SUBDIR}
  endif
  if ( ${?LD_LIBRARY_PATH} ) then
    setenv LD_LIBRARY_PATH ${DIR}/lib/${BELLE2_SUBDIR}:${LD_LIBRARY_PATH}
  else
    setenv LD_LIBRARY_PATH ${DIR}/lib/${BELLE2_SUBDIR}
  endif
  if ( ${?PYTHONPATH} ) then
    setenv PYTHONPATH ${DIR}/lib/${BELLE2_SUBDIR}:${PYTHONPATH}
  else
    setenv PYTHONPATH ${DIR}/lib/${BELLE2_SUBDIR}
  endif

  # add externals directory to path and library path
  setenv PATH ${DIR}/externals/bin/${BELLE2_SUBDIR}:${PATH}
  setenv LD_LIBRARY_PATH ${DIR}/externals/lib/${BELLE2_SUBDIR}:${LD_LIBRARY_PATH}

  # setup geant4 environment
  if ( -f ${DIR}/externals/geant4/env.csh ) then
    source ${DIR}/externals/geant4/env.csh > /dev/null
  endif

  # set ROOTSYS
  if ( -d ${DIR}/externals/root ) then
    setenv ROOTSYS ${DIR}/externals/root
  endif

  # set environment variables
  setenv BELLE2_LOCAL_DIR ${DIR}
endif

# set environment variables
if ( ${?RELEASE} ) then
  setenv BELLE2_RELEASE ${RELEASE}
endif

# clean up
unset DIR
unset LOCAL_RELEASE
unset RELEASE
