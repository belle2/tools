# check whether we are in a release directory
if ( ! -f .release ) then
  echo "Not in a release directory."
  exit
endif

# add release directory to path and library path
set DIR=$PWD
set ARCH=`uname`_`uname -m`
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

# setup root
setenv ROOTSYS ${DIR}/externals/root
setenv PATH ${ROOTSYS}/bin:${PATH}
setenv LD_LIBRARY_PATH ${ROOTSYS}/lib:${LD_LIBRARY_PATH}

unset DIR
unset ARCH
