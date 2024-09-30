#!/bin/bash
# Make sure we exit on each error
set -e

# Now setup everything ...
echo "Sourcing tools ..."
source ${BELLE2_TOOLS}/b2setup
echo "Getting recommended release ..."
RECOMMENDED=$(b2help-releases)

# Create venv with recommended release if it exists for this platform
if [ -d "${VO_BELLE2_SW_DIR}/releases/${RECOMMENDED}" ]; then
    echo "Trying to create venv with recommended release ..."
    b2venv -n local_venv -s "source  ${BELLE2_TOOLS}/b2setup" ${RECOMMENDED}

    # Check if venv was created
    echo "Checking if venv directory exist ..."
    ls local_venv/bin/activate

    # Check if venv activation works
    echo "Activating venv ..."
    source local_venv/bin/activate

    # Check that basf2 works
    echo "Trying to run basf2 --info"
    basf2 --info

    # Clean up venv direcotries
    rm -rf venv
    rm -rf local_venv

fi