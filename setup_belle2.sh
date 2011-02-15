# add tools directory to path
export BELLE2_TOOLS=$(readlink -f "`dirname $BASH_SOURCE`")
if [ -n "${PATH}" ]; then
  export PATH=${BELLE2_TOOLS}:${PATH}
else
  export PATH=${BELLE2_TOOLS}
fi

# set top directory of Belle II software installation
if [ -z "${VO_BELLE2_SW_DIR}" ]; then
  export VO_BELLE2_SW_DIR=$(readlink -f "${BELLE2_TOOLS}/..")
fi

# set location of Belle II code repository
export BELLE2_REPOSITORY=https://b2comp.kek.jp

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
