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

    # set the code option to something
    b2code-option clang
    if ! [ "$BELLE2_OPTION" == "clang" ]; then
        echo "Failed to set compiler option to clang"
        exit 1
    fi
fi

# echo execute at least one of the functions intended to modify the environment
b2code-option --help

# now make sure everything also works when sourcing from a relative directory after changing it
echo "Try again relative"
pushd $BELLE2_TOOLS/tests
source ../b2setup.sh
pushd $(mktemp -d)
b2code-option --help
