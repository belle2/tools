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
alias setuprel source ${BELLE2_TOOLS}/setuprel.csh
