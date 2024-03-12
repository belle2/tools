#!/bin/bash
# Make sure we exit on each error
set -e
# Now setup the tools and get the recommended release ...
echo "Sourcing tools ..."
source ${BELLE2_TOOLS}/b2setup
echo "Getting recommended release ..."
RECOMMENDED=$(b2help-releases)
# Define the output file
OUTPUT_FILE=${BELLE2_TOOLS}/tests/test_output_file.root
# Run the test steering file with b2execute
echo "Executing test_steering_file.py with ${RECOMMENDED} and a simple option via b2execute..."
b2execute ${RECOMMENDED} ${BELLE2_TOOLS}/tests/test_steering_file.py -n 10 -o ${OUTPUT_FILE}
# Check if also b2execute -x works
echo "Executing b2file-metadata-show with ${RECOMMENDED} and a simple option via b2execute..."
b2execute -x b2file-metadata-show ${RECOMMENDED} ${OUTPUT_FILE} -a
# Clean the output file(s)
rm -rf ${OUTPUT_FILE}
