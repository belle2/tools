# add tools directory to path
export BELLE2_TOOLS=`python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $(dirname ${BASH_SOURCE:-$0})`
if [ -n "${PATH}" ]; then
  export PATH=${BELLE2_TOOLS}:${PATH}
else
  export PATH=${BELLE2_TOOLS}
fi
if [ -n "${PYTHONPATH}" ]; then
  export PYTHONPATH=${BELLE2_TOOLS}:${PYTHONPATH}
else
  export PYTHONPATH=${BELLE2_TOOLS}
fi

# set top directory of Belle II software installation
if [ -z "${VO_BELLE2_SW_DIR}" ]; then
  export VO_BELLE2_SW_DIR=`python -c 'import os,sys;print os.path.realpath(sys.argv[1])' ${BELLE2_TOOLS}/..`
fi

# set top directory of external software
if [ -z "${BELLE2_EXTERNALS_TOPDIR}" ]; then
  export BELLE2_EXTERNALS_TOPDIR=${VO_BELLE2_SW_DIR}/externals
fi

# set architecture, default option and sub directory name
export BELLE2_ARCH=`uname -s`_`uname -m`
export BELLE2_OPTION=debug
export BELLE2_SUBDIR=${BELLE2_ARCH}/${BELLE2_OPTION}
export BELLE2_EXTERNALS_OPTION=opt
export BELLE2_EXTERNALS_SUBDIR=${BELLE2_ARCH}/${BELLE2_EXTERNALS_OPTION}

# set location of Belle II code repository
export BELLE2_REPOSITORY=https://belle2.cc.kek.jp/svn

# define function for release setup
function setuprel
{
  tmp=`mktemp /tmp/belle2_tmp.XXXX`
  rm -f $tmp
  ${BELLE2_TOOLS}/setuprel.py $* > $tmp
  . $tmp
  rm -f $tmp
}

# define function for analysis setup
function setupana
{
  tmp=`mktemp /tmp/belle2_tmp.XXXX`
  rm -f $tmp
  ${BELLE2_TOOLS}/setupana.py $* > $tmp
  . $tmp
  rm -f $tmp
}

# define function for option selection
function setoption
{
  tmp=`mktemp /tmp/belle2_tmp.XXXX`
  rm -f $tmp
  ${BELLE2_TOOLS}/setoption.py $* > $tmp
  . $tmp
  rm -f $tmp
}

# define function for externals option selection
function setextoption
{
  tmp=`mktemp /tmp/belle2_tmp.XXXX`
  rm -f $tmp
  ${BELLE2_TOOLS}/setextoption.py $* > $tmp
  . $tmp
  rm -f $tmp
}

# set scons library directory
export SCONS_LIB_DIR=${BELLE2_TOOLS}/lib

# setup own gcc
if [ -z "${BELLE2_SYSTEM_COMPILER}" ]; then
  if [ -f ${BELLE2_TOOLS}/gcc/bin/gcc ]; then
    export PATH=${BELLE2_TOOLS}/gcc/bin:${PATH}
    if [ -n "${LD_LIBRARY_PATH}" ]; then
      export LD_LIBRARY_PATH=${BELLE2_TOOLS}/gcc/lib:${BELLE2_TOOLS}/gcc/lib64:${LD_LIBRARY_PATH}
    else
      export LD_LIBRARY_PATH=${BELLE2_TOOLS}/gcc/lib:${BELLE2_TOOLS}/gcc/lib64
    fi
  fi
fi

# setup own python
if [ -z "${BELLE2_SYSTEM_PYTHON}" ]; then\
  if [ -f ${BELLE2_TOOLS}/virtualenv/bin/activate ]; then
    export PATH=${BELLE2_TOOLS}/python/bin:${PATH}
    export LD_LIBRARY_PATH=${BELLE2_TOOLS}/python/lib:${LD_LIBRARY_PATH}
    VIRTUAL_ENV_DISABLE_PROMPT=1 source ${BELLE2_TOOLS}/virtualenv/bin/activate
    export PYTHONHOME=${BELLE2_TOOLS}/python
  fi
fi

# inform user about successful setup
echo "Belle II software tools set up at: ${BELLE2_TOOLS}"

# check for a newer version
if [ -z "${BELLE2_NO_TOOLS_CHECK}" ]; then
  tmp=`mktemp /tmp/belle2_tmp.XXXX`
  svn status -u -q --non-interactive ${BELLE2_TOOLS} > $tmp 2> /dev/null
  if [ $? != 0 ]; then
    echo
    echo "Warning: Could not access svn in non-interactive mode."
    echo "-------> Please make sure you can successfully run the following command"
    echo "         WITHOUT interactive input:"
    echo
    echo "           svn list ${BELLE2_REPOSITORY}"
    echo
  elif [ `cat $tmp | cut -c 9 | grep \* | wc -l` != 0 ]; then
    echo
    echo "WARNING: The version of the tools you are using is outdated."
    echo "-------> Please update the tools and source the new setup_belle2 script."
    echo
  fi
  rm -f $tmp
fi
