#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import subprocess

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

# determine which kind of shell we have
shell = (subprocess.Popen(('ps -p %d -o comm=' % os.getppid()).split(),
         stdout=subprocess.PIPE).communicate()[0])[:-1]
csh = shell in ['csh', 'tcsh']

# if the release version is given as argument take it from there
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

# dictionary for new envionment variables
env_vars = {}


def copy_from_environment(var, default=None):
    """helper function to take a variable from the environment or a default, and to split paths"""

    if os.environ.has_key(var):
        env_vars[var] = os.environ[var]
    else:
        env_vars[var] = default
    if env_vars[var] and env_vars[var].find(':') >= 0:
        env_vars[var] = env_vars[var].split(':')


def add_path(path, entry):
    """helper function to add an entry to a path"""

    if not env_vars.has_key(path):
        copy_from_environment(path)
        add_path(path, entry)
    elif not env_vars[path]:
        env_vars[path] = [entry]
    elif isinstance(env_vars[path], str):
        env_vars[path] = [entry, env_vars[path]]
    else:
        (env_vars[path])[:0] = [entry]


def remove_path(path, entry):
    """helper function to remove an entry from a path"""

    if not env_vars.has_key(path):
        copy_from_environment(path)
        remove_path(path, entry)
    elif not env_vars[path]:
        return
    elif isinstance(env_vars[path], str):
        if env_vars[path] == entry:
            env_vars[path] = []
    elif entry in env_vars[path]:
        env_vars[path].remove(entry)


def add_option(var, option):
    """helper function to add an option to a variable"""

    if not env_vars.has_key(var):
        if os.environ.has_key(var):
            env_vars[var] = os.environ[var]
        else:
            env_vars[var] = ''
    env_vars[var] = (env_vars[var] + ' ' + option).strip()


def remove_option(var, option):
    """helper function to remove an option from a variable"""

    if not env_vars.has_key(var):
        if os.environ.has_key(var):
            env_vars[var] = os.environ[var]
        else:
            return
    env_vars[var] = env_vars[var].replace(' ' + option, '').replace(option, ''
            ).strip()


# define variables
unamelist = os.uname()
env_vars['BELLE2_ARCH'] = unamelist[0] + '_' + unamelist[4]
copy_from_environment('BELLE2_OPTION', 'debug')
subdir = os.path.join(env_vars['BELLE2_ARCH'], env_vars['BELLE2_OPTION'])
env_vars['BELLE2_SUBDIR'] = subdir


def unsetup_release(location):
    """function to unsetup a release directory"""

    # externals
    remove_path('PATH', os.path.join(location, 'externals', 'bin', subdir))
    remove_path('LD_LIBRARY_PATH', os.path.join(location, 'externals', 'lib',
                subdir))
    # geant4
    if os.environ.has_key('G4SYSTEM'):
        remove_path('LD_LIBRARY_PATH', os.path.join(os.environ['G4LIB'],
                    os.environ['G4SYSTEM']))
        remove_path('LD_LIBRARY_PATH', os.environ['CLHEP_LIB_DIR'])
        remove_path('PATH', os.path.join(os.environ['G4WORKDIR'], 'bin',
                    os.environ['G4SYSTEM']))
    # root
    root_dir = os.path.join(location, 'externals', 'root')
    if env_vars.has_key('ROOTSYS') and env_vars['ROOTSYS'] == root_dir:
        env_vars['ROOTSYS'] = ''
    remove_path('PATH', os.path.join(root_dir, 'bin'))
    remove_path('LD_LIBRARY_PATH', os.path.join(root_dir, 'lib'))
    # release
    remove_path('PATH', os.path.join(location, 'bin', subdir))
    remove_path('LD_LIBRARY_PATH', os.path.join(location, 'lib', subdir))
    remove_path('PYTHONPATH', os.path.join(location, 'lib', subdir))


def setup_release(location):
    """function to setup a release directory"""

    # add externals directory to path and library path
    add_path('PATH', os.path.join(location, 'externals', 'bin', subdir))
    add_path('LD_LIBRARY_PATH', os.path.join(location, 'externals', 'lib',
             subdir))

    # setup root
    root_dir = os.path.join(location, 'externals', 'root')
    if os.path.isdir(root_dir):
        env_vars['ROOTSYS'] = root_dir
    add_path('PATH', os.path.join(root_dir, 'bin'))
    add_path('LD_LIBRARY_PATH', os.path.join(root_dir, 'lib'))

    # add release directory to path, library path, and python path
    add_path('PATH', os.path.join(location, 'bin', subdir))
    add_path('LD_LIBRARY_PATH', os.path.join(location, 'lib', subdir))
    add_path('PYTHONPATH', os.path.join(location, 'lib', subdir))


# remove path settings from old release
if os.environ.has_key('BELLE2_RELEASE_DIR'):
    unsetup_release(os.environ['BELLE2_RELEASE_DIR'])
env_vars['BELLE2_RELEASE_DIR'] = ''
if os.environ.has_key('BELLE2_LOCAL_DIR'):
    unsetup_release(os.environ['BELLE2_LOCAL_DIR'])
    remove_option('SCONSFLAGS', '-C ' + os.environ['BELLE2_LOCAL_DIR'])
env_vars['BELLE2_LOCAL_DIR'] = ''
env_vars['BELLE2_EXTERNALS_DIR'] = ''

# setup the central release if it exists
location = os.path.join(os.environ['VO_BELLE2_SW_DIR'], 'releases', release)
if release != 'head':
    if not os.path.isdir(location):
        sys.stderr.write('Warning: No central release %s found.\n' % release)
        release = None
    else:

        setup_release(location)
        env_vars['BELLE2_RELEASE_DIR'] = location
        env_vars['BELLE2_EXTERNALS_DIR'] = os.path.join(location, 'externals')

# take care of local release
location = os.getcwd()
if local_release:
    release = local_release
    setup_release(location)
    env_vars['BELLE2_LOCAL_DIR'] = location
    env_vars['BELLE2_EXTERNALS_DIR'] = os.path.join(location, 'externals')
    add_option('SCONSFLAGS', '-C ' + location)

# export release version
env_vars['BELLE2_RELEASE'] = release

# generate shell commands for environment settings
for var in env_vars.keys():
    value = env_vars[var]
    if isinstance(value, list):
        value = ':'.join(value)
    if value and len(value) > 0:
        if csh:
            print 'setenv %s "%s"' % (var, value)
        else:
            print 'export %s="%s"' % (var, value)
    else:
        if csh:
            print 'unsetenv %s' % var
        else:
            print 'unset %s' % var

# setup geant4 environment
geant_dir = os.path.join(env_vars['BELLE2_EXTERNALS_DIR'], 'geant4')
if os.path.isdir(geant_dir):
    if csh:
        print 'source %s > /dev/null' % os.path.join(geant_dir, 'env.csh')
    else:
        print 'source %s > /dev/null' % os.path.join(geant_dir, 'env.sh')

# inform user about successful completion
print 'echo "Environment setup for release: ${BELLE2_RELEASE}"'
if len(env_vars['BELLE2_RELEASE_DIR']) > 0:
    print 'echo "Central release directory    : ${BELLE2_RELEASE_DIR}"'
print 'echo "Local release directory      : ${BELLE2_LOCAL_DIR}"'

# check for geant4 and root and warn the user if they are missing
need_externals = False
if not os.path.isfile(os.path.join(env_vars['BELLE2_LOCAL_DIR'], 'externals',
                      'geant4', 'env.sh')):
    if len(env_vars['BELLE2_RELEASE_DIR']) == 0 \
        or not os.path.isfile(os.path.join(env_vars['BELLE2_RELEASE_DIR'],
                              'externals', 'geant4', 'end.sh')):
        need_externals = True
        sys.stderr.write('Warning: geant4 installation is missing.\n')
if not os.path.isfile(os.path.join(env_vars['BELLE2_LOCAL_DIR'], 'externals',
                      'root', 'bin', 'root.exe')):
    if len(env_vars['BELLE2_RELEASE_DIR']) == 0 \
        or not os.path.isfile(os.path.join(env_vars['BELLE2_RELEASE_DIR'],
                              'externals', 'root', 'bin', 'root.exe')):
        need_externals = True
        sys.stderr.write('Warning: root installation is missing.\n')
if need_externals:
    if os.path.isdir(os.path.join(env_vars['BELLE2_RELEASE_DIR'], 'externals'
                     )):
        sys.stderr.write('-> Build externals: scons externals\n')
    else:
        sys.stderr.write('-> Install and build externals: addpkg externals; scons externals\n'
                         )
