# -*- coding: utf-8 -*-
import sys
import os
from setup_tools import update_environment

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

# update environment with new externals option
update_environment(externals_option=sys.argv[1])

# inform user about successful completion
print('echo "Environment setup for externals option: %s"' % sys.argv[1])
