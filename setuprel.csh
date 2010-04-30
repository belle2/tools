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

# check whether a central release exists
set ARCH=`uname`_`uname -m`
set DIR=${VO_BELLE2_SW_DIR}/releases/${RELEASE}
if ( "${RELEASE}" != "head" ) then
  if ( ! -d ${DIR} ) then
    echo "Warning: No central release ${RELEASE} found."
    unset RELEASE

  else
    # add release directory to path and library path
    if ( ${?PATH} ) then
      setenv PATH ${DIR}/bin/${ARCH}:${PATH}
    else
      setenv PATH ${DIR}/bin/${ARCH}
    endif
    if ( ${?LD_LIBRARY_PATH} ) then
      setenv LD_LIBRARY_PATH ${DIR}/lib/${ARCH}:${LD_LIBRARY_PATH}
    else
      setenv LD_LIBRARY_PATH ${DIR}/lib/${ARCH}
    endif

    # add externals directory to path and library path
    setenv PATH ${DIR}/externals/bin/${ARCH}:${PATH}
    setenv LD_LIBRARY_PATH ${DIR}/externals/lib/${ARCH}:${LD_LIBRARY_PATH}

    # set ROOTSYS
    setenv ROOTSYS ${DIR}/externals/root
  endif
endif

# take care of local release
set DIR=$PWD
if ( ${?LOCAL_RELEASE} ) then
  set RELEASE=${LOCAL_RELEASE}

  # add release directory to path and library path
  if ( ${?PATH} ) then
    setenv PATH ${DIR}/bin/${ARCH}:${PATH}
  else
    setenv PATH ${DIR}/bin/${ARCH}
  endif
  if ( ${?LD_LIBRARY_PATH} ) then
    setenv LD_LIBRARY_PATH ${DIR}/lib/${ARCH}:${LD_LIBRARY_PATH}
  else
    setenv LD_LIBRARY_PATH ${DIR}/lib/${ARCH}
  endif

  # add externals directory to path and library path
  setenv PATH ${DIR}/externals/bin/${ARCH}:${PATH}
  setenv LD_LIBRARY_PATH ${DIR}/externals/lib/${ARCH}:${LD_LIBRARY_PATH}

  # set ROOTSYS
  if ( -d ${DIR}/externals/root ) then
    setenv ROOTSYS ${DIR}/externals/root
  endif
endif

# set environment variables
if ( ${?RELEASE} ) then
  setenv BELLE2_RELEASE ${RELEASE}
endif
if ( ${?LOCAL_RELEASE} ) then
  setenv BELLE2_LOCAL ${DIR}
endif

# clean up
unset DIR
unset ARCH
unset LOCAL_RELEASE
unset RELEASE
