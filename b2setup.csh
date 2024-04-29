# determine tools directory
set COMMAND=`echo $_`
if ( "${COMMAND}" != "" ) then
  set FILENAME=`echo ${COMMAND} | awk '{print $2}'`
else if ( $?BELLE2_TOOLS ) then
  set FILENAME=${BELLE2_TOOLS}/b2setup.csh
else if ( $?VO_BELLE2_SW_DIR ) then
  set FILENAME=${VO_BELLE2_SW_DIR}/tools/b2setup.csh
else if ( -f ${HOME}/tools/b2setup.csh ) then
  set FILENAME=${HOME}/tools/b2setup.csh
else if ( -f tools/b2setup.csh ) then
  set FILENAME=tools/b2setup.csh
else if ( -f b2setup.csh ) then
  set FILENAME=b2setup.csh
else
  echo "No tools folder found"
  exit 1
endif
set DIRNAME=`dirname ${FILENAME}`
setenv BELLE2_TOOLS `${DIRNAME}/b2anypython -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' ${DIRNAME}`
unset DIRNAME
unset FILENAME

# check for pre setup script
set BELLE2_SETUP_DIRS="${PWD}"
if ( ${?HOME} ) then
  set BELLE2_SETUP_DIRS="${BELLE2_SETUP_DIRS} ${HOME}"
endif
set BELLE2_SETUP_DIRS="${BELLE2_SETUP_DIRS} ${BELLE2_TOOLS}"
if ( ${?BELLE2_CONFIG_DIR} ) then
  set BELLE2_SETUP_DIRS="${BELLE2_SETUP_DIRS} ${BELLE2_CONFIG_DIR}"
endif
set BELLE2_SETUP_DIRS="${BELLE2_SETUP_DIRS} /etc /sw/belle2"
foreach DIR ( ${BELLE2_SETUP_DIRS} )
  if ( -f ${DIR}/b2presetup.csh ) then
    source ${DIR}/b2presetup.csh
    rehash
    break
  endif
end

# add tools directory to path
if ( ${?PATH} ) then
  setenv PATH "${BELLE2_TOOLS}:${PATH}"
else
  setenv PATH ${BELLE2_TOOLS}
endif
if ( ${?PYTHONPATH} ) then
  if ( "${PYTHONPATH}" != "${BELLE2_TOOLS}" ) then
    echo "Warning: Changing existing PYTHONPATH from ${PYTHONPATH} to ${BELLE2_TOOLS}"
  endif
endif
setenv PYTHONPATH ${BELLE2_TOOLS}

# set top directory of Belle II software installation
if ( ! ${?VO_BELLE2_SW_DIR} ) then
  setenv VO_BELLE2_SW_DIR `${BELLE2_TOOLS}/b2anypython -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' ${BELLE2_TOOLS}/..`
endif

# set top directory of external software
if ( ! ${?BELLE2_EXTERNALS_TOPDIR} ) then
  setenv BELLE2_EXTERNALS_TOPDIR ${VO_BELLE2_SW_DIR}/externals
endif

# set architecture, default option and sub directory name
setenv BELLE2_ARCH `uname -s`_`uname -m`
if ( ! ${?BELLE2_OPTION} ) then
  setenv BELLE2_OPTION opt
endif
setenv BELLE2_SUBDIR ${BELLE2_ARCH}/${BELLE2_OPTION}
if ( ! ${?BELLE2_EXTERNALS_OPTION} ) then
  setenv BELLE2_EXTERNALS_OPTION opt
endif
setenv BELLE2_EXTERNALS_SUBDIR ${BELLE2_ARCH}/${BELLE2_EXTERNALS_OPTION}

# set user name
if ( ! ${?BELLE2_USER} ) then
  setenv BELLE2_USER ${USER}
  if ( ! ${?BELLE2_USER} ) then
    setenv BELLE2_USER `id -nu`
  endif
endif

# set location of Belle II code repositories
pushd ${BELLE2_TOOLS} > /dev/null
set ORIGIN_URL=`git remote -v`
popd > /dev/null
if ( ! ${?BELLE2_GIT_SERVER} ) then
  if ( ! ${?BELLE2_GIT_ACCESS} ) then
    set BELLE2_GIT_ACCESS=""
  endif
  if ( "${ORIGIN_URL}" =~ "*gitlab.desy*" ) then
    if ( "${BELLE2_GIT_ACCESS}" == "http" ) then
      setenv BELLE2_GIT_SERVER https://gitlab.desy.de/
    else
      setenv BELLE2_GIT_SERVER git@gitlab.desy.de:
    endif
    set BELLE2_GIT_PROJECT=belle2/software
  else
    if ( "${BELLE2_GIT_ACCESS}" == "http" ) then
      setenv BELLE2_GIT_SERVER https://github.com/
    else
      setenv BELLE2_GIT_SERVER git@github.com:
    endif
    set BELLE2_GIT_PROJECT=belle2
  endif
endif
if ( ! ${?BELLE2_SOFTWARE_REPOSITORY} ) then
  setenv BELLE2_SOFTWARE_REPOSITORY ${BELLE2_GIT_SERVER}${BELLE2_GIT_PROJECT}/basf2.git
endif
if ( ! ${?BELLE2_EXTERNALS_REPOSITORY} ) then
  setenv BELLE2_EXTERNALS_REPOSITORY ${BELLE2_GIT_SERVER}${BELLE2_GIT_PROJECT}/externals.git
endif
if ( ! ${?BELLE2_VERSIONING_REPOSITORY} ) then
  setenv BELLE2_VERSIONING_REPOSITORY ${BELLE2_GIT_SERVER}${BELLE2_GIT_PROJECT}/versioning.git
endif
if ( ! ${?BELLE2_ANALYSES_PROJECT} ) then
  if ( "${ORIGIN_URL}" =~ "*gitlab.desy*" ) then
    setenv BELLE2_ANALYSES_PROJECT belle2/analyses
  else
    setenv BELLE2_ANALYSES_PROJECT b2a
  endif
endif
if ( ! ${?BELLE2_DOWNLOAD} ) then
  setenv BELLE2_DOWNLOAD "--ca-certificate=${BELLE2_TOOLS}/certchain.pem https://software.belle2.org/download"
endif

# list of packages that are excluded by default
if ( ! ${?BELLE2_EXCLUDE_PACKAGES} ) then
  setenv BELLE2_EXCLUDE_PACKAGES "daq"
endif

# define alias for release/analysis setup
alias b2setup "source ${BELLE2_TOOLS}/source.csh b2anypython ${BELLE2_TOOLS}/b2setup.py --csh"

# define alias for option selection
alias b2code-option "source ${BELLE2_TOOLS}/source.csh b2anypython ${BELLE2_TOOLS}/b2code-option.py --csh"

# define alias for externals option selection
alias b2code-option-externals "source ${BELLE2_TOOLS}/source.csh b1anypython ${BELLE2_TOOLS}/b2code-option-externals.py --csh"

# define alias for externals setup without release
alias b2setup-externals "source ${BELLE2_TOOLS}/source.csh b2anypython ${BELLE2_TOOLS}/b2setup-externals.py --csh"

# make PATH changes active
rehash

# inform user about successful setup
echo "Belle II software tools set up at: ${BELLE2_TOOLS}"

# check for a newer version
if ( ! ${?BELLE2_NO_TOOLS_CHECK} ) then
  pushd ${BELLE2_TOOLS} > /dev/null
  set BELLE2_TMP=`mktemp /tmp/belle2_tmp.XXXX`
  (git fetch --dry-run > /dev/tty) >& ${BELLE2_TMP}
  if ( $? != 0 ) then
    echo
    echo "Warning: Could not access remote git repository in non-interactive mode."
    echo "-------> Please make sure you can successfully run the following command"
    echo "         WITHOUT interactive input:"
    echo
    echo "           git -C ${BELLE2_TOOLS} fetch --dry-run"
    echo
  else
    set FETCH_CHECK=`cat $BELLE2_TMP | grep -v X11 | wc -l`
    set LOCAL=`git rev-parse HEAD`
    set REMOTE=`git rev-parse @\{upstream\}`
    if ( ${FETCH_CHECK} != 0 || ${LOCAL} != ${REMOTE} ) then
      echo
      echo "WARNING: The version of the tools you are using is outdated."
      echo "-------> Please update the tools with"
      echo
      echo "           git -C ${BELLE2_TOOLS} pull --rebase"
      echo
      echo "         and source the new b2setup script."
      echo
    endif
    unset FETCH_CHECK
    unset LOCAL
    unset REMOTE
  endif
  rm -f $BELLE2_TMP
  popd  > /dev/null
endif

# check encoding
set ENCODING=`b2anypython -c 'import locale;print(locale.getpreferredencoding())'`
if ( "${ENCODING}" != "UTF-8" ) then
  echo
  echo "WARNING: Your preferred character encoding is not UTF-8."
  echo "-------> It is recommended to enable UFT-8 encoding, see 'man locale' for instructions."
  echo
endif


# check for post setup script
foreach DIR ( ${BELLE2_SETUP_DIRS} )
  if ( -f ${DIR}/b2postsetup.csh ) then
    source ${DIR}/b2postsetup.csh
    rehash
    break
  endif
end

# do release setup if in a release or analysis directory, or MY_BELLE2_DIR or MY_BELLE2_RELEASE set, or release specified
if ( -f .release || -f .analysis || ${?MY_BELLE2_DIR} || ${?MY_BELLE2_RELEASE} || "$1" != "" ) then
  b2setup "$*"
endif
