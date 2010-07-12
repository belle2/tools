# add tools directory to path
set FILENAME=`echo $_ | awk '{print $2}'`
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

# set location of Belle II code repository
setenv BELLE2_REPOSITORY https://b2comp.kek.jp

# define alias for release setup
set BELLE2_TMP=`mktemp`
rm $BELLE2_TMP
alias setuprel "${BELLE2_TOOLS}/setuprel.py $* > $BELLE2_TMP; source $BELLE2_TMP; rm -f $BELLE2_TMP; rehash"

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
