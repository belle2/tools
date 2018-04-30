#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import os
from setup_tools import get_var, set_var, export_environment

# allowed options
options = ['debug', 'opt', 'intel']

# check for help option
if len(sys.argv) >= 2 and sys.argv[1] in ['--help', '-h', '-?']:
    sys.stderr.write("""
Usage: b2code-option-externals %s
    
Set up the environment for selected compiler options for the externals:

  debug   : include debug symbols, no optimization
  opt     : turn on optimization (-O3), no debug symbols
  intel   : use the intel compiler

"""
                     % '|'.join(options))
    sys.exit(0)

# check arguments
if len(sys.argv) != 2 or sys.argv[1] not in options:
    sys.stderr.write('Usage: setextoption %s\n' % '|'.join(options))
    sys.stderr.write('The current option is: %s\n'
                     % os.environ.get('BELLE2_EXTERNALS_OPTION',
                     '***UNDEFINED***'))
    sys.exit(1)

# remove externals from the environment
extdir = os.environ.get('BELLE2_EXTERNALS_DIR', None)
if extdir:
    try:
        sys.path[:0] = [extdir]
        from externals import unsetup_externals
        unsetup_externals(extdir)
    except:
        sys.stderr.write('Warning: Unsetup of externals at %s failed.\n'
                         % extdir)

# set new compilation option
set_var('BELLE2_EXTERNALS_OPTION', sys.argv[1])
set_var('BELLE2_EXTERNALS_SUBDIR', os.path.join(os.environ.get('BELLE2_ARCH'),
        sys.argv[1]))

# update environment with new externals option
if extdir:
    try:
        sys.path[:0] = [extdir]
        from externals import setup_externals, check_externals
        setup_externals(extdir)
        if not check_externals(extdir):
            sys.stderr.write('Error: Check of externals at %s failed.\n'
                             % extdir)
    except:
        sys.stderr.write('Error: Setup of externals at %s failed.\n' % extdir)

export_environment()

# inform user about successful completion
print('echo "Environment setup for externals option: %s"' % sys.argv[1])
