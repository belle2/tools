#!/bin/bash
# Make sure we exit on each error
set -e
# Now setup the tools and get the recommended release ...
echo "Sourcing tools ..."
source ${BELLE2_TOOLS}/b2setup
echo "Getting recommended release ..."
RECOMMENDED=$(b2help-releases)
# Run the test steering file with b2execute
echo "Executing test_steering_file.py with ${RECOMMENDED} and a simple option..."
b2execute ${RECOMMENDED} ${BELLE2_TOOLS}/tests/test_steering_file.py -n 10
