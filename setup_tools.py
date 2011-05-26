#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import subprocess

# determine whether we have a csh family kind of shell
shell = (subprocess.Popen(('ps -p %d -o comm=' % os.getppid()).split(),
         stdout=subprocess.PIPE).communicate()[0])[:-1]
csh = shell in ['csh', 'tcsh']

# dictionary for envionment variables
env_vars = {}


def set_var(var, value):
    env_vars[var] = value


def get_var(var):
    return env_vars[var]


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


def set_subdir():
    """define BELLE2_ARCH and BELLE2_SUBDIR variables"""

    unamelist = os.uname()
    env_vars['BELLE2_ARCH'] = unamelist[0] + '_' + unamelist[4]
    if not env_vars.has_key('BELLE2_OPTION'):
        copy_from_environment('BELLE2_OPTION', 'debug')
    subdir = os.path.join(env_vars['BELLE2_ARCH'], env_vars['BELLE2_OPTION'])
    env_vars['BELLE2_SUBDIR'] = subdir


def unsetup_release(location):
    """function to unsetup a release directory"""

    subdir = os.environ['BELLE2_SUBDIR']

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
    remove_path('PYTHONPATH', os.path.join(root_dir, 'lib'))
    # release
    remove_path('PATH', os.path.join(location, 'bin', subdir))
    remove_path('LD_LIBRARY_PATH', os.path.join(location, 'lib', subdir))
    remove_path('PYTHONPATH', os.path.join(location, 'lib', subdir))


def setup_release(location):
    """function to setup a release directory"""

    subdir = env_vars['BELLE2_SUBDIR']

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
    add_path('PYTHONPATH', os.path.join(root_dir, 'lib'))

    # add release directory to path, library path, and python path
    add_path('PATH', os.path.join(location, 'bin', subdir))
    add_path('LD_LIBRARY_PATH', os.path.join(location, 'lib', subdir))
    add_path('PYTHONPATH', os.path.join(location, 'lib', subdir))


def unsetup_old_release():
    """remove path settings from old release"""

    if os.environ.has_key('BELLE2_RELEASE_DIR'):
        unsetup_release(os.environ['BELLE2_RELEASE_DIR'])
    env_vars['BELLE2_RELEASE_DIR'] = ''
    if os.environ.has_key('BELLE2_LOCAL_DIR'):
        unsetup_release(os.environ['BELLE2_LOCAL_DIR'])
        remove_option('SCONSFLAGS', '-C ' + os.environ['BELLE2_LOCAL_DIR'])
    env_vars['BELLE2_LOCAL_DIR'] = ''
    env_vars['BELLE2_EXTERNALS_DIR'] = ''


def setup_central_release(release):
    """setup the central release if it exists"""

    if release and release != 'head':
        location = os.path.join(os.environ['VO_BELLE2_SW_DIR'], 'releases',
                                release)
        if not os.path.isdir(location):
            sys.stderr.write('Warning: No central release %s found.\n'
                             % release)
            release = None
        else:

            setup_release(location)
            env_vars['BELLE2_RELEASE_DIR'] = location
            env_vars['BELLE2_EXTERNALS_DIR'] = os.path.join(location,
                    'externals')


def setup_local_release(location):
    """setup a local release directory"""

    setup_release(location)
    env_vars['BELLE2_LOCAL_DIR'] = location
    if os.path.isdir(os.path.join(location, 'externals')):
        env_vars['BELLE2_EXTERNALS_DIR'] = os.path.join(location, 'externals')
    add_option('SCONSFLAGS', '-C ' + location)


def export_environment():
    """generate shell commands for environment settings"""

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


def externals_setup():
    """setup environment for externals, currently just geant4"""

    geant_dir = os.path.join(env_vars['BELLE2_EXTERNALS_DIR'], 'geant4')
    if os.path.isdir(geant_dir):
        if csh:
            print 'source %s > /dev/null' % os.path.join(geant_dir, 'env.csh')
        else:
            print 'source %s > /dev/null' % os.path.join(geant_dir, 'env.sh')


def update_environment(release, local_release, local_dir):
    """update the environment for the given central and local release"""

    # add the new central release to the environment
    set_subdir()
    setup_central_release(release)

    # take care of the local release
    if local_release:
        release = local_release
        setup_local_release(local_dir)

    # export release version
    env_vars['BELLE2_RELEASE'] = release

    # setup environment for the release, including the externals
    export_environment()
    externals_setup()


