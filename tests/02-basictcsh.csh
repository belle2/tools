#!/bin/tcsh -e
# sometimes helpful to debug errors ...
#set verbose
#set echo
echo "Sourcing tools ..."
source ${BELLE2_TOOLS}/b2setup.csh
echo "Getting recommended release ..."
set RECOMMENDED=`b2help-releases`
# setup recommended release if it exists for this platform
if ( -d "${VO_BELLE2_SW_DIR}/releases/${RECOMMENDED}" ) then
    echo "Trying to setup recommended release ..."
    b2setup ${RECOMMENDED}
    echo "Trying to run basf2 --info"
    basf2 --info
endif

# echo execute at least one of the functions intended to modify the environment
b2code-option --help
