# determine tools directory
BELLE2_TOOLS=`python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $(dirname ${BASH_SOURCE:-$0})`

# check for pre setup script
BELLE2_SETUP_DIRS="${PWD} ${HOME} ${BELLE2_TOOLS} ${BELLE2_CONFIG_DIR} /etc /sw/belle2"
for DIR in `echo ${BELLE2_SETUP_DIRS}`; do
  if [ -f ${DIR}/b2presetup.sh ]; then
    source ${DIR}/b2presetup.sh
    break
  fi
done

# add tools directory to path
export BELLE2_TOOLS
if [ -n "${PATH}" ]; then
  export PATH=${BELLE2_TOOLS}:${PATH}
else
  export PATH=${BELLE2_TOOLS}
fi
if [ -n "${PYTHONPATH}" -a "${PYTHONPATH}" != "${BELLE2_TOOLS}" ]; then
  echo "Warning: Changing existing PYTHONPATH from ${PYTHONPATH} to ${BELLE2_TOOLS}"
fi
export PYTHONPATH=${BELLE2_TOOLS}

# set top directory of Belle II software installation
if [ -z "${VO_BELLE2_SW_DIR}" ]; then
  export VO_BELLE2_SW_DIR=`python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' ${BELLE2_TOOLS}/..`
fi

# set top directory of external software
if [ -z "${BELLE2_EXTERNALS_TOPDIR}" ]; then
  export BELLE2_EXTERNALS_TOPDIR=${VO_BELLE2_SW_DIR}/externals
fi

# set architecture, default option and sub directory name
export BELLE2_ARCH=`uname -s`_`uname -m`
export BELLE2_OPTION=opt
export BELLE2_SUBDIR=${BELLE2_ARCH}/${BELLE2_OPTION}
export BELLE2_EXTERNALS_OPTION=opt
export BELLE2_EXTERNALS_SUBDIR=${BELLE2_ARCH}/${BELLE2_EXTERNALS_OPTION}

# set user name
if [ -z "${BELLE2_USER}" ]; then
  export BELLE2_USER=${USER}
  if [ -z "${BELLE2_USER}" ]; then
    export BELLE2_USER=`id -nu`
  fi
fi

# set location of Belle II code repositories
if [ -z "${BELLE2_GIT_SERVER}" ]; then
  if [ "${BELLE2_GIT_ACCESS}" = "http" ]; then
    export BELLE2_GIT_SERVER=https://${BELLE2_USER}@stash.desy.de/scm
  else
    export BELLE2_GIT_SERVER=ssh://git@stash.desy.de:7999
  fi
fi
if [ -z "${BELLE2_SOFTWARE_REPOSITORY}" ]; then
  export BELLE2_SOFTWARE_REPOSITORY=${BELLE2_GIT_SERVER}/b2/software.git
fi
if [ -z "${BELLE2_EXTERNALS_REPOSITORY}" ]; then
  export BELLE2_EXTERNALS_REPOSITORY=${BELLE2_GIT_SERVER}/b2/externals.git
fi
if [ -z "${BELLE2_ANALYSES_PROJECT}" ]; then
  export BELLE2_ANALYSES_PROJECT=b2a
fi
if [ -z "${BELLE2_DOWNLOAD}" ]; then
  export BELLE2_DOWNLOAD="--ca-certificate=${BELLE2_TOOLS}/certchain.pem --user=belle2 --password=Aith4tee https://b2-master.belle2.org/download"
fi

# list of packages that are excluded by default
if [ -z "${BELLE2_EXCLUDE_PACKAGES}" ]; then
  export BELLE2_EXCLUDE_PACKAGES="daq eutel topcaf testbeam"
fi

# define function for release/analysis setup
function b2setup
{
  eval "`python ${BELLE2_TOOLS}/b2setup.py $* || echo 'return 1'`"
}

# define function for option selection
function b2code-option
{
  eval "`python ${BELLE2_TOOLS}/b2code-option.py $* || echo 'return 1'`"
}

# define function for externals option selection
function b2code-option-externals
{
  eval "`python ${BELLE2_TOOLS}/b2code-option-externals.py $* || echo 'return 1'`"
}

# define function for externals setup without release
function b2setup-externals
{
  eval "`python ${BELLE2_TOOLS}/b2setup-externals.py $* || echo 'return 1'`"
}

# inform user about successful setup
echo "Belle II software tools set up at: ${BELLE2_TOOLS}"

# check for a newer version
if [ -z "${BELLE2_NO_TOOLS_CHECK}" ]; then
  pushd ${BELLE2_TOOLS} > /dev/null
  tmp=`mktemp /tmp/belle2_tmp.XXXX`
  git fetch --dry-run 2> $tmp
  if [ $? != 0 ]; then
    echo
    echo "Warning: Could not access remote git repository in non-interactive mode."
    echo "-------> Please make sure you can successfully run the following command"
    echo "         WITHOUT interactive input:"
    echo
    echo "           git -C ${BELLE2_TOOLS} fetch --dry-run"
    echo
  else
    FETCH_CHECK=`cat $tmp | grep -v X11 | wc -l`
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse @{upstream})
    if [ ${FETCH_CHECK} != 0 -o ${LOCAL} != ${REMOTE} ]; then
      echo
      echo "WARNING: The version of the tools you are using is outdated."
      echo "-------> Please update the tools with"
      echo
      echo "           git -C ${BELLE2_TOOLS} pull --rebase"
      echo
      echo "         and source the new b2setup script."
      echo
    fi
  fi
  rm -f $tmp
  popd  > /dev/null
fi

# check for post setup script
for DIR in `echo ${BELLE2_SETUP_DIRS}`; do
  if [ -f ${DIR}/b2postsetup.sh ]; then
    source ${DIR}/b2postsetup.sh
    break
  fi
done

# do release setup if in a release or analysis directory, or MY_BELLE2_DIR or MY_BELLE2_RELEASE set, or release specified
if [ -f .release ] || [ -f .analysis ] || [ -n "${MY_BELLE2_DIR}" ] || [ -n "${MY_BELLE2_RELEASE}" ] || [ "$1" != "" ]; then
  b2setup "$@"
fi
