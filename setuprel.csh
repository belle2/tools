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

# add externals directory to path and library path
setenv PATH ${DIR}/externals/bin/${ARCH}:${PATH}
setenv LD_LIBRARY_PATH ${DIR}/externals/lib/${ARCH}:${LD_LIBRARY_PATH}

# set ROOTSYS
setenv ROOTSYS ${DIR}/externals/root

unset DIR
unset ARCH
