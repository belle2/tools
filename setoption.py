#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
from setup_tools import get_var, set_var, unsetup_old_release, \
    update_environment, export_environment

# allowed options
options = ['debug', 'opt', 'intel']

# check for help option
if len(sys.argv) >= 2 and sys.argv[1] in ['--help', '-h', '-?']:
    sys.stderr.write("""
Usage: setoption %s
    
Set up the environment for selected compiler options:

  debug : include debug symbols, no optimization
  opt   : turn on optimization (-O3), no debug symbols
  intel : use the intel compiler

"""
                     % '|'.join(options))
    sys.exit(0)

# check arguments
if len(sys.argv) != 2 or sys.argv[1] not in options:
    sys.stderr.write('Usage: setoption %s\n' % '|'.join(options))
    sys.stderr.write('The current option is: %s\n'
                     % os.environ.get('BELLE2_OPTION', ''))
    sys.exit(1)

# get current setup variables
release = None
if os.environ.has_key('BELLE2_RELEASE_DIR'):
    release = os.path.split(os.environ['BELLE2_RELEASE_DIR'])[-1]
local_release = None
local_dir = None
if os.environ.has_key('BELLE2_LOCAL_DIR'):
    local_release = os.environ['BELLE2_RELEASE']
    local_dir = os.environ['BELLE2_LOCAL_DIR']

# remove old release from the environment
if release or local_release:
    unsetup_old_release()

# set new compilation option
set_var('BELLE2_OPTION', sys.argv[1])
set_var('BELLE2_SUBDIR', os.path.join(os.environ.get('BELLE2_ARCH'),
        sys.argv[1]))
if not os.environ.has_key('BELLE2_EXTERNALS_OPTION'):
    set_var('BELLE2_EXTERNALS_SUBDIR',
            os.path.join(os.environ.get('BELLE2_ARCH'), sys.argv[1]))
    if os.environ.has_key('BELLE2_EXTERNALS_DIR'):
        extdir = os.environ.get('BELLE2_EXTERNALS_DIR')
        try:
            sys.path[:0] = [extdir]
            from externals import check_externals
            if not check_externals(extdir):
                sys.stderr.write('''Warning: The externals installation is incomplete.
-> Try: cd %s; make
'''
                                 % extdir)
        except:
            sys.stderr.write('Warning: Check of externals at %s failed.\n'
                             % extdir)

# update environment with new
if release or local_release:
    update_environment(release, local_release, local_dir)
else:
    export_environment()

# inform user about successful completion
print 'echo "Environment setup for build option: ${BELLE2_OPTION}"'
