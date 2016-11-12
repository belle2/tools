#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import os
from setup_tools import get_var, unsetup_old_release, update_environment, csh

# check for help option
if len(sys.argv) >= 2 and sys.argv[1] in ['--help', '-h', '-?']:
    sys.stderr.write("""
Usage: setuprel [release]

This command sets up the environment for a local and/or central release
of the Belle II software.

-> Local (+ central) release setup:

  Execute the setuprel command in the local release directory. If a centrally
  installed release with the same version as the local one exists, it is set
  up, too. (If a release version is given as argument this is used as version
  for the central release instead of the one matching the local release.)

-> Central release setup (without a local release):

  Execute the setuprel command outside a local release directory with the
  central release version as argument.

""")

    releases = []
    releases_topdir = os.path.join(os.environ['VO_BELLE2_SW_DIR'], 'releases')
    if os.path.isdir(releases_topdir):
        for entry in os.listdir(releases_topdir):
            if entry.find('.') < 0 and not os.path.isfile(entry):
                releases.append(entry)

    if len(releases) > 0:
        sys.stderr.write('  The following releases are available:\n')
        for rel in releases:
            sys.stderr.write('    %s\n' % rel)
    else:
        sys.stderr.write('  There are no central releases available.\n')
    sys.stderr.write('\n')

    sys.exit(0)

# check number of arguments
if len(sys.argv) > 2:
    sys.stderr.write('Usage: setuprel [release]\n')
    sys.exit(1)

# if the MY_BELLE2_DIR environment variable is set use it as local release directory
if 'MY_BELLE2_DIR' in os.environ:
    os.chdir(os.environ['MY_BELLE2_DIR'])

# if the release version is given as argument or environment variable take it from there
release = None
if len(sys.argv) == 2:
    release = sys.argv[1]
elif 'MY_BELLE2_RELEASE' in os.environ:
    release = os.environ['MY_BELLE2_RELEASE']

# determine local release version and directory by looking for .release file in current and parent directories
local_release = None
local_dir = os.path.abspath(os.getcwd())
while len(local_dir) > 1 and not os.path.isfile(os.path.join(local_dir, '.release')):
    local_dir = os.path.dirname(local_dir)
if os.path.isfile(os.path.join(local_dir, '.release')):
    local_release = open(os.path.join(local_dir, '.release')).readline().strip()

# if central release version given:
if release:

    # check whether the central release exists
    if not os.path.isdir(os.path.join(os.environ['VO_BELLE2_SW_DIR'],
                                      'releases', release)):
        sys.stderr.write('Error: No central release %s found.\n' % release)
        sys.exit(1)

    # check whether it matches the release in the current directory
    if local_release and local_release != release:
        sys.stderr.write('Warning: The given release (%s) differs from the one in the current directory (%s).\n'
                         % (release, local_release))
else:  # if no central release version given:

    if not local_release:
        sys.stderr.write('Error: Not in a release directory.\n')
        sys.exit(1)

    if len(local_release) == 0:
        sys.stderr.write('Error: The .release file is empty.\n')
        sys.exit(1)

    release = local_release

# remove old release from the environment
unsetup_old_release()

# add the new release
update_environment(release, local_release, local_dir)

# check SConstruct is a symlink to site_scons/SConstruct
if local_release and not os.path.islink(os.path.join(local_dir, 'SConstruct')):
    sys.stderr.write(
        'ERROR: "SConstruct" should be a symbolic link to site_scons/SConstruct, but it doesn\'t exist or is a copy.\n')
    sys.stderr.write('Please remove it and recreate the link with\n')
    sys.stderr.write(' ln -s site_scons/SConstruct .\n')
    sys.exit(1)

# inform user about successful completion
print('echo "Environment setup for release: ${BELLE2_RELEASE}"')
if len(get_var('BELLE2_RELEASE_DIR')) > 0:
    print('echo "Central release directory    : ${BELLE2_RELEASE_DIR}"')
if len(get_var('BELLE2_LOCAL_DIR')) > 0:
    print('echo "Local release directory      : ${BELLE2_LOCAL_DIR}"')

# set the build option if a .option file exists in the local release directory
if os.path.isfile(os.path.join(local_dir, '.option')):
    build_option = open(os.path.join(local_dir, '.option')).readline().strip()
    print('setoption %s' % build_option)

# check the externals and warn the user if the check fails
try:
    extdir = get_var('BELLE2_EXTERNALS_DIR')
    sys.path[:0] = [extdir]
    from externals import check_externals
    if not check_externals(extdir):
        sys.stderr.write('Error: Check of externals at %s failed.\n' % extdir)
except:
    sys.stderr.write('Error: Check of externals at %s failed.\n' % extdir)
