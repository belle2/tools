# setup Belle II software tools
set COMMAND=`echo $_`
if ( "${COMMAND}" != "" ) then
  set FILENAME=`echo ${COMMAND} | awk '{print $2}'`
else if ( $?BELLE2_TOOLS ) then
  set FILENAME=${BELLE2_TOOLS}/setup_belle2_ana.csh
else if ( $?VO_BELLE2_SW_DIR ) then
  set FILENAME=${VO_BELLE2_SW_DIR}/tools/setup_belle2_ana.csh
else if ( -f ${HOME}/tools/setup_belle2_ana.csh ) then
  set FILENAME=${HOME}/tools/setup_belle2_ana.csh
else if ( -f tools/setup_belle2_ana.csh ) then
  set FILENAME=tools/setup_belle2_ana.csh
else if ( -f setup_belle2_ana.csh ) then
  set FILENAME=setup_belle2_ana.csh
else
  echo "No tools folder found"
  exit 1
endif
set DIRNAME=`dirname ${FILENAME}`
source `dirname ${FILENAME}`/setup_belle2.csh

# setup the analysis if the current directory contains Belle II analysis code
if ( -f .analysis ) then
  setupana $*
endif
