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
setenv BELLE2_TOOLS `readlink -f "${DIRNAME}"`
unset DIRNAME
unset FILENAME
if ( ${?PATH} ) then
  setenv PATH ${BELLE2_TOOLS}:${PATH}
else
  setenv PATH ${BELLE2_TOOLS}
endif

# set top directory of Belle II software installation
if ( ! ${?VO_BELLE2_SW_DIR} ) then
  setenv VO_BELLE2_SW_DIR `readlink -f "${BELLE2_TOOLS}/.."`
endif

# set top directory of external software
if ( ! ${?BELLE2_EXTERNALS_TOPDIR} ) then
  setenv BELLE2_EXTERNALS_TOPDIR ${VO_BELLE2_SW_DIR}/externals
endif

# set architecture, default option and sub directory name
setenv BELLE2_ARCH `uname -s`_`uname -m`
setenv BELLE2_OPTION debug
setenv BELLE2_SUBDIR ${BELLE2_ARCH}/${BELLE2_OPTION}
setenv BELLE2_EXTERNALS_OPTION debug
setenv BELLE2_EXTERNALS_SUBDIR ${BELLE2_SUBDIR}

# set location of Belle II code repository
setenv BELLE2_REPOSITORY https://ekpbelle2.physik.uni-karlsruhe.de

# define alias for release setup
set BELLE2_TMP=`mktemp`
rm -f $BELLE2_TMP
alias setuprel "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setuprel.py"

# define alias for option selection
alias setoption "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setoption.py"

# define alias for externals option selection
alias setextoption "source ${BELLE2_TOOLS}/source.csh ${BELLE2_TOOLS}/setextoption.py"

# set scons library directory
setenv SCONS_LIB_DIR ${BELLE2_TOOLS}/lib

# set up svn if it is installed in the Belle II software directory
if ( -d ${VO_BELLE2_SW_DIR}/subversion ) then
  setenv PATH ${VO_BELLE2_SW_DIR}/subversion/bin:$PATH
  if ( ${?LD_LIBRARY_PATH} ) then
    setenv LD_LIBRARY_PATH ${VO_BELLE2_SW_DIR}/subversion/lib:${LD_LIBRARY_PATH}
  else
    setenv LD_LIBRARY_PATH ${VO_BELLE2_SW_DIR}/subversion/lib
  endif
endif

# make PATH changes active
rehash

# inform user about successful setup
echo "Belle II software tools set up at: ${BELLE2_TOOLS}"
