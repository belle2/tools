#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
from setup_tools import get_var, unsetup_old_release, update_environment

# check for help option
if len(sys.argv) >= 2 and sys.argv[1] in ['--help', '-h', '-?']:
    sys.stderr.write("""
Usage: setuprel [release]
    
- To set up the environment for a local copy of the Belle II software,
  execute the setuprel command in the local release directoy.
- If a centrally installed release with the same version as the local one
  exists, it is set up, too.
- A particular version of a central release can be set up explicitly
  by giving the release version as argument.

""")
    sys.exit(0)

# check number of arguments
if len(sys.argv) > 2:
    sys.stderr.write('Usage: setuprel [release]\n')
    sys.exit(1)

# if the release version is given as argument take it from there
local_release = None
if len(sys.argv) == 2:
    release = sys.argv[1]

    # check whether it matches the release in the current directory
    if os.path.isfile('.release'):
        local_release = open('.release').readline().strip()

        if local_release != release:
            sys.stderr.write('Warning: The given release (%s) differs from the one in the current directory (%s). Ignoring the local version.\n'
                              % (release, local_release))

            if not os.path.isdir(os.path.join(os.environ['VO_BELLE2_SW_DIR'],
                                 'releases', release)):
                sys.stderr.write('Error: No central release %s found.\n'
                                 % release)
                sys.exit(1)
else:

    # check whether we are in a release directory and take the release version from there
    if not os.path.isfile('.release'):
        sys.stderr.write('Error: Not in a release directory.\n')
        sys.exit(1)

    local_release = open('.release').readline().strip()
    release = local_release

# remove old release from the environment
unsetup_old_release()

# add the new release
update_environment(release, local_release, os.getcwd())

# inform user about successful completion
print 'echo "Environment setup for release: ${BELLE2_RELEASE}"'
if len(get_var('BELLE2_RELEASE_DIR')) > 0:
    print 'echo "Central release directory    : ${BELLE2_RELEASE_DIR}"'
if len(get_var('BELLE2_LOCAL_DIR')) > 0:
    print 'echo "Local release directory      : ${BELLE2_LOCAL_DIR}"'

# check for geant4 and root and warn the user if they are missing
need_externals = False
if not os.path.isfile(os.path.join(get_var('BELLE2_LOCAL_DIR'), 'externals',
                      'geant4', 'env.sh')):
    if len(get_var('BELLE2_RELEASE_DIR')) == 0 \
        or not os.path.isfile(os.path.join(get_var('BELLE2_RELEASE_DIR'),
                              'externals', 'geant4', 'env.sh')):
        need_externals = True
        sys.stderr.write('Warning: geant4 installation is missing.\n')
if not os.path.isfile(os.path.join(get_var('BELLE2_LOCAL_DIR'), 'externals',
                      'root', 'bin', 'root.exe')):
    if len(get_var('BELLE2_RELEASE_DIR')) == 0 \
        or not os.path.isfile(os.path.join(get_var('BELLE2_RELEASE_DIR'),
                              'externals', 'root', 'bin', 'root.exe')):
        need_externals = True
        sys.stderr.write('Warning: root installation is missing.\n')
if need_externals:
    if os.path.isdir(os.path.join(get_var('BELLE2_RELEASE_DIR'), 'externals')):
        sys.stderr.write('-> Build externals: scons externals\n')
    else:
        sys.stderr.write('-> Install and build externals: addpkg externals; scons externals\n'
                         )
