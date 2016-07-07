# add tools directory to path
set COMMAND=`echo $_`
if ( "${COMMAND}" != "" ) then
  set FILENAME=`echo ${COMMAND} | awk '{print $2}'`
else if ( $?BELLE2_TOOLS ) then
  set FILENAME=${BELLE2_TOOLS}/setup_belle2.csh
else if ( $?VO_BELLE2_SW_DIR ) then
  set FILENAME=${VO_BELLE2_SW_DIR}/tools/setup_belle2.csh
else if ( -f ${HOME}/tools/setup_belle2.csh ) then
  set FILENAME=${HOME}/tools/setup_belle2.csh
else if ( -f tools/setup_belle2.csh ) then
  set FILENAME=tools/setup_belle2.csh
else if ( -f setup_belle2.csh ) then
  set FILENAME=setup_belle2.csh
else
  echo "No tools folder found"
  exit 1
endif
set DIRNAME=`dirname ${FILENAME}`
setenv BELLE2_TOOLS `python -c 'from __future__ import print_function; import os,sys;print(os.path.realpath(sys.argv[1]))' ${DIRNAME}`
unset DIRNAME
unset FILENAME
if ( ${?PATH} ) then
  setenv PATH ${BELLE2_TOOLS}:${PATH}
else
  setenv PATH ${BELLE2_TOOLS}
endif
if ( ${?PYTHONPATH} ) then
  setenv PYTHONPATH ${BELLE2_TOOLS}:${PYTHONPATH}
else
  setenv PYTHONPATH ${BELLE2_TOOLS}
endif

# set top directory of Belle II software installation
if ( ! ${?VO_BELLE2_SW_DIR} ) then
  setenv VO_BELLE2_SW_DIR `python -c 'from __future__ import print_function; import os,sys;print(os.path.realpath(sys.argv[1]))' ${BELLE2_TOOLS}/..`
endif

# set top directory of external software
if ( ! ${?BELLE2_EXTERNALS_TOPDIR} ) then
  setenv BELLE2_EXTERNALS_TOPDIR ${VO_BELLE2_SW_DIR}/externals
endif

# set architecture, default option and sub directory name
setenv BELLE2_ARCH `uname -s`_`uname -m`
setenv BELLE2_OPTION opt
setenv BELLE2_SUBDIR ${BELLE2_ARCH}/${BELLE2_OPTION}
setenv BELLE2_EXTERNALS_OPTION opt
setenv BELLE2_EXTERNALS_SUBDIR ${BELLE2_ARCH}/${BELLE2_EXTERNALS_OPTION}

# set user name
if ( ! ${?BELLE2_USER} ) then
  setenv BELLE2_USER ${USER}
  if ( ! ${?BELLE2_USER} ) then
    setenv BELLE2_USER `id -nu`
  endif
endif

# set location of Belle II code repositories
if ( ! ${?BELLE2_GIT_SERVER} ) then
  if ( ! ${?BELLE2_GIT_ACCESS} ) then
    set BELLE2_GIT_ACCESS ""
  endif 
  if ( "${BELLE2_GIT_ACCESS}" == "ssh" || ( "${BELLE2_GIT_ACCESS}" != "http" && -f ${HOME}/.ssh/id_rsa.pub ) ) then
    setenv BELLE2_GIT_SERVER ssh://git@stash.desy.de:7999
  else
    setenv BELLE2_GIT_SERVER https://${BELLE2_USER}@stash.desy.de/scm
  endif
endif
if ( ! ${?BELLE2_SOFTWARE_REPOSITORY} ) then
  setenv BELLE2_SOFTWARE_REPOSITORY ${BELLE2_GIT_SERVER}/b2/software.git
endif
if ( ! ${?BELLE2_EXTERNALS_REPOSITORY} ) then
  setenv BELLE2_EXTERNALS_REPOSITORY ${BELLE2_GIT_SERVER}/b2/externals.git
endif
if ( ! ${?BELLE2_ANALYSES_PROJECT} ) then
  setenv BELLE2_ANALYSES_PROJECT b2a
endif
if ( ! ${?BELLE2_DOWNLOAD} ) then
  setenv BELLE2_DOWNLOAD "--user=belle2 --password=Aith4tee https://b2-master.belle2.org/download"
endif

# list of packages that are excluded by default
if ( ! ${?BELLE2_EXCLUDE_PACKAGES} ) then
  setenv BELLE2_EXCLUDE_PACKAGES "daq eutel topcaf testbeam"
endif

# define alias for release setup
alias setuprel "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setuprel.py"

# define alias for analysis setup
alias setupana "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setupana.py"

# define alias for option selection
alias setoption "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setoption.py"

# define alias for externals option selection
alias setextoption "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setextoption.py"

# make PATH changes active
rehash

# inform user about successful setup
echo "Belle II software tools set up at: ${BELLE2_TOOLS}"

# check python version
python -c 'import sys; assert(sys.hexversion>0x02070600)' >& /dev/null
if ( $? != 0 ) then
  echo "Warning: Your Python version is too old, basf2 will not work properly." 
endif

# check for a newer version
if ( ! ${?BELLE2_NO_TOOLS_CHECK} ) then
  pushd ${BELLE2_TOOLS} > /dev/null
  git fetch --dry-run >& /dev/null
  if ( $? != 0 ) then
    echo
    echo "Warning: Could not access remote git repository in non-interactive mode."
    echo "-------> Please make sure you can successfully run the following command"
    echo "         WITHOUT interactive input:"
    echo
    echo "           git fetch --dry-run"
    echo
  else
    set BELLE2_TMP=`mktemp /tmp/belle2_tmp.XXXX`
    git fetch --dry-run |& grep -v X11 > ${BELLE2_TMP}
    set FETCH_CHECK=`cat $BELLE2_TMP | wc -l`
    rm -f $BELLE2_TMP
    set LOCAL=`git rev-parse HEAD`
    set REMOTE=`git rev-parse @\{upstream\}`
    if ( ${FETCH_CHECK} != 0 || ${LOCAL} != ${REMOTE} ) then
      echo
      echo "WARNING: The version of the tools you are using is outdated."
      echo "-------> Please update the tools with"
      echo
      echo "           git pull --rebase"
      echo
      echo "         and source the new setup_belle2 script."
      echo
    endif
    unset FETCH_CHECK
    unset LOCAL
    unset REMOTE
  endif
  popd  > /dev/null
endif
