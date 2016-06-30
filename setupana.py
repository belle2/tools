#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function
import sys
import os
from setup_tools import get_var, unsetup_old_release, update_environment

# check for help option
if len(sys.argv) >= 2 and sys.argv[1] in ['--help', '-h', '-?']:
    sys.stderr.write("""
Usage: setupana

This command sets up the environment for an analysis with the Belle II
software. Execute the setupana command in the local analysis directory.

""")

# check number of arguments
if len(sys.argv) > 1:
    sys.stderr.write('Usage: setupana\n')
    sys.exit(1)

# check whether we are in an analysis directory and take the release version from there
if not os.path.isfile('.analysis'):
    sys.stderr.write('Error: Not in an analysis directory.\n')
    sys.exit(1)

release = open('.analysis').readline().strip()

# remove old release from the environment
unsetup_old_release()

# add the new release
update_environment(release, 'analysis', os.getcwd())

# inform user about successful completion
print('echo "Environment setup for analysis : ${BELLE2_ANALYSIS_DIR}"')
print('echo "Central release directory      : ${BELLE2_RELEASE_DIR}"')

# set the build option if a .option file exists in the local analysis directory
if os.path.isfile('.option'):
    build_option = open('.option').readline().strip()
    print('setoption %s' % build_option)

