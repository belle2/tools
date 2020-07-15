#!/bin/bash
# Make sure we exit on each error
set -e
# Now setup everything ...
echo "Sourcing tools ..."
source ${BELLE2_TOOLS}/b2setup
echo "Getting recommended release ..."
RECOMMENDED=$(b2help-releases)
# setup recommended release if it exists for this platform
if [ -d "${VO_BELLE2_SW_DIR}/releases/${RECOMMENDED}" ]; then
    echo "Trying to setup recommended release ..."
    b2setup ${RECOMMENDED}
    echo "Trying to run basf2 --info"
    basf2 --info
fi
