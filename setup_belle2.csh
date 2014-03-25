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
setenv BELLE2_TOOLS `python -c 'import os,sys;print os.path.realpath(sys.argv[1])' ${DIRNAME}`
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
  setenv VO_BELLE2_SW_DIR `python -c 'import os,sys;print os.path.realpath(sys.argv[1])' ${BELLE2_TOOLS}/..`
endif

# set top directory of external software
if ( ! ${?BELLE2_EXTERNALS_TOPDIR} ) then
  setenv BELLE2_EXTERNALS_TOPDIR ${VO_BELLE2_SW_DIR}/externals
endif

# set architecture, default option and sub directory name
setenv BELLE2_ARCH `uname -s`_`uname -m`
setenv BELLE2_OPTION debug
setenv BELLE2_SUBDIR ${BELLE2_ARCH}/${BELLE2_OPTION}
setenv BELLE2_EXTERNALS_OPTION opt
setenv BELLE2_EXTERNALS_SUBDIR ${BELLE2_ARCH}/${BELLE2_EXTERNALS_OPTION}

# set location of Belle II code repository
setenv BELLE2_REPOSITORY https://belle2.cc.kek.jp/svn

# define alias for release setup
set BELLE2_TMP=`mktemp /tmp/belle2_tmp.XXXX`
rm -f $BELLE2_TMP
alias setuprel "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setuprel.py"

# define alias for analysis setup
alias setupana "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setupana.py"

# define alias for option selection
alias setoption "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setoption.py"

# define alias for externals option selection
alias setextoption "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setextoption.py"

# set scons library directory
setenv SCONS_LIB_DIR ${BELLE2_TOOLS}/lib

# setup own gcc
if ( ! ${?BELLE2_SYSTEM_COMPILER} ) then
  if ( -f ${BELLE2_TOOLS}/gcc/bin/gcc ) then
    setenv PATH ${BELLE2_TOOLS}/gcc/bin:${PATH}
    if ( ${?LD_LIBRARY_PATH} ) then
      setenv LD_LIBRARY_PATH ${BELLE2_TOOLS}/gcc/lib:${BELLE2_TOOLS}/gcc/lib64:${LD_LIBRARY_PATH}
    else
      setenv LD_LIBRARY_PATH ${BELLE2_TOOLS}/gcc/lib:${BELLE2_TOOLS}/gcc/lib64
    endif
  endif
endif

# setup own python
if ( ! ${?BELLE2_SYSTEM_PYTHON} ) then
  if ( -f ${BELLE2_TOOLS}/virtualenv/bin/activate ) then
    setenv PATH ${BELLE2_TOOLS}/python/bin:${PATH}
    setenv LD_LIBRARY_PATH ${BELLE2_TOOLS}/python/lib:${LD_LIBRARY_PATH}
    set _SAVE_PROMPT="$prompt"
    source ${BELLE2_TOOLS}/virtualenv/bin/activate.csh
    set prompt="$_SAVE_PROMPT"
    setenv PYTHONHOME ${BELLE2_TOOLS}/python
  endif
endif

# make PATH changes active
rehash

# inform user about successful setup
echo "Belle II software tools set up at: ${BELLE2_TOOLS}"

# check for a newer version
if ( ! ${?BELLE2_NO_TOOLS_CHECK} ) then
  (svn status -u -q --non-interactive ${BELLE2_TOOLS} > ${BELLE2_TMP}) >& /dev/null
  if ( $? != 0 ) then
    echo
    echo "Warning: Could not access svn in non-interactive mode."
    echo "-------> Please make sure you can successfully run the following command"
    echo "         WITHOUT interactive input:"
    echo
    echo "           svn list ${BELLE2_REPOSITORY}"
    echo
  else if ( `cat $BELLE2_TMP | cut -c 9 | grep \* | wc -l` != 0 ) then
    echo
    echo "WARNING: The version of the tools you are using is outdated."
    echo "-------> Please update the tools and source the new setup_belle2 script."
    echo
  endif
  rm -f $BELLE2_TMP
endif
