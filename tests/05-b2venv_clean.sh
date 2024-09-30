#!/bin/bash
# Make sure we exit on each error
set -e

# The venv directory should be present from the previous test
if [ -d "venv" ]; then
    # Check if venv activation works
    echo "Trying to activate venv ..."
    source venv/bin/activate

else
    echo "venv directory not found. Exiting..."
    exit 1
fi