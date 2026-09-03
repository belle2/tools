#!/bin/bash
# Make sure we exit on each error
set -e

# This test doesn't need any release, externals or cvmfs installation, so it can
# run before all the other tests. We always use the tools directory containing
# this script, so that the test can also be executed on its own.
TOOLS_DIR=$(cd -P $(dirname $0)/.. && pwd -P)

echo "Running the unit tests of setup_tools.py ..."
${TOOLS_DIR}/b2anypython ${TOOLS_DIR}/tests/setup_tools_tests.py
