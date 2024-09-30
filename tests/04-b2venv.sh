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
    b2venv ${RECOMMENDED}

    # Check if venv was created
    echo "Checking if venv directory exist ..."
    ls venv/bin/activate

    # Check if venv activation works
    echo "Activating venv ..."
    source venv/bin/activate

    # Check that basf2 works
    echo "Trying to run basf2 --info"
    basf2 --info

    # Default package manager is pip so try to install a package
    echo "Install a package and check for it's location ..."
    pip3 --quiet --no-cache-dir install --upgrade b2luigi &> /dev/null
    ls venv/lib/python*/site-packages/b2luigi &> /dev/null

fi