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

    # Install a Python package under user site-packages directory
    #  -> check later that it is later not available in the venv
    b2setup ${RECOMMENDED}
    pip3 --quiet --no-cache-dir install --user b2luigi &> /dev/null

    echo "Trying to create venv with recommended release ..."
    rm -rf venv
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

    # Check that the previously installed package is not available in the venv
    if python3 -c "import b2luigi" 2>/dev/null; then
        exit 1
    fi

    # Default package manager is pip so try to install a package
    echo "Install a package and check for it's location ..."
    pip3 --quiet --no-cache-dir install --upgrade b2luigi &> /dev/null

    # Check that b2luigi is available in the venv
    b2luigi_path=$(python3 -c "import b2luigi; print(b2luigi.__file__)" 2>/dev/null)
    if [[ ! $b2luigi_path == *"venv/lib"* ]]; then
        exit 1
    fi

    # Checking that packages from the externals are correctly linked
    echo "Checking that packages from the externals are correctly linked ..."
    pandas_path=$(python3 -c "import pandas; print(pandas.__file__)" 2>/dev/null)
    python_path=$(readlink -f $(which python3))

    if [[ $? -ne 0 || $pandas_path != *externals* ]]; then
        exit 1
    fi
    if [[ $? -ne 0 || $python_path != *externals* ]]; then
        exit 1
    fi

    # Checking that the output of b2piplist is not empty
    if [[ -n "$(b2piplist)" ]]; then
        exit 1
    fi

    # Check that local python project can be installed
    export BELLE2_MOCK_UP_PROJECT="${BELLE2_TOOLS}/my_mock_project"
    export BELLE2_MOCK_UP_PACKAGE="my_mock_package"
    python3 ${BELLE2_TOOLS}/tests/mock_up_package.py
    pip3 --quiet --no-cache-dir install -e ${BELLE2_MOCK_UP_PROJECT} &> /dev/null
    if ! python3 -c "import ${BELLE2_MOCK_UP_PACKAGE}" 2>/dev/null; then
        exit 1
    fi
    rm -rf ${BELLE2_MOCK_UP_PROJECT}
fi
