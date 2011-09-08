# add tools directory to path
export BELLE2_TOOLS=$(readlink -f "`dirname ${BASH_SOURCE:-$0}`")
if [ -n "${PATH}" ]; then
  export PATH=${BELLE2_TOOLS}:${PATH}
else
  export PATH=${BELLE2_TOOLS}
fi

# set top directory of Belle II software installation
if [ -z "${VO_BELLE2_SW_DIR}" ]; then
  export VO_BELLE2_SW_DIR=$(readlink -f "${BELLE2_TOOLS}/..")
fi

# set top directory of external software
if [ -z "${BELLE2_EXTERNALS_TOPDIR}" ]; then
  export BELLE2_EXTERNALS_TOPDIR=${VO_BELLE2_SW_DIR}/externals
fi

# set architecture, default option and sub directory name
export BELLE2_ARCH=`uname -s`_`uname -m`
export BELLE2_OPTION=debug
export BELLE2_SUBDIR=${BELLE2_ARCH}/${BELLE2_OPTION}
export BELLE2_EXTERNALS_SUBDIR=${BELLE2_SUBDIR}

# set location of Belle II code repository
export BELLE2_REPOSITORY=https://ekpbelle2.physik.uni-karlsruhe.de

# define function for release setup
function setuprel
{
  tmp=`mktemp`
  ${BELLE2_TOOLS}/setuprel.py $* > $tmp
  . $tmp
  rm -f $tmp
}

# define function for option selection
function setoption
{
  tmp=`mktemp`
  ${BELLE2_TOOLS}/setoption.py $* > $tmp
  . $tmp
  rm -f $tmp
}

# define function for externals option selection
function setextoption
{
  tmp=`mktemp`
  ${BELLE2_TOOLS}/setextoption.py $* > $tmp
  . $tmp
  rm -f $tmp
}

# set scons library directory
export SCONS_LIB_DIR=${BELLE2_TOOLS}/lib

# set up svn if it is installed in the Belle II software directory
if [ -d ${VO_BELLE2_SW_DIR}/subversion ]; then
  export PATH=${VO_BELLE2_SW_DIR}/subversion/bin:$PATH
  if [ -n "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH=${VO_BELLE2_SW_DIR}/subversion/lib:${LD_LIBRARY_PATH}
  else
    export LD_LIBRARY_PATH=${VO_BELLE2_SW_DIR}/subversion/lib
  fi
fi

# inform user about successful setup
echo "Belle II software tools set up at: ${BELLE2_TOOLS}"
