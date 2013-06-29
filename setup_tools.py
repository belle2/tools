#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import subprocess

# determine whether we have a csh family kind of shell
shell = (subprocess.Popen(('ps -p %d -o comm=' % os.getppid()).split(),
         stdout=subprocess.PIPE).communicate()[0])[:-1]
csh = shell in ['csh', 'tcsh']

# determine library path environment variable
lib_path_name = 'LD_LIBRARY_PATH'
if os.uname()[0] == 'Darwin':
    lib_path_name = 'DYLD_LIBRARY_PATH'

# dictionary for envionment variables
env_vars = {}

# list of [sh, csh] scripts that should be sourced
source_scripts = []


def set_var(var, value):
    env_vars[var] = value
    os.environ[var] = value
    if len(value) == 0:
        del os.environ[var]


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
        if entry != env_vars[path]:
            env_vars[path] = [entry, env_vars[path]]
    else:
        while env_vars[path].count(entry) > 0:
            env_vars[path].remove(entry)
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
        while env_vars[path].count(entry) > 0:
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


def unsetup_release(location):
    """function to unsetup a release directory"""

    subdir = os.environ['BELLE2_SUBDIR']

    # remove release directory to path, library path, and python path
    remove_path('PATH', os.path.join(location, 'bin', subdir))
    remove_path(lib_path_name, os.path.join(location, 'lib', subdir))
    remove_path('PYTHONPATH', os.path.join(location, 'lib', subdir))


def setup_release(location):
    """function to setup a release directory"""

    subdir = os.environ['BELLE2_SUBDIR']

    # add release directory to path, library path, and python path
    add_path('PATH', os.path.join(location, 'bin', subdir))
    add_path(lib_path_name, os.path.join(location, 'lib', subdir))
    add_path('PYTHONPATH', os.path.join(location, 'lib', subdir))


def unsetup_old_release():
    """remove path settings from old release"""

    # central release
    if os.environ.has_key('BELLE2_RELEASE_DIR'):
        unsetup_release(os.environ['BELLE2_RELEASE_DIR'])
    env_vars['BELLE2_RELEASE_DIR'] = ''

    # local release
    if os.environ.has_key('BELLE2_LOCAL_DIR'):
        unsetup_release(os.environ['BELLE2_LOCAL_DIR'])
    env_vars['BELLE2_LOCAL_DIR'] = ''

    # externals
    if os.environ.has_key('BELLE2_EXTERNALS_DIR'):
        try:
            sys.path[:0] = [os.environ['BELLE2_EXTERNALS_DIR']]
            from externals import unsetup_externals
            unsetup_externals(os.environ['BELLE2_EXTERNALS_DIR'])
        except:
            sys.stderr.write('Warning: Unsetup of externals at %s failed.\n'
                             % os.environ['BELLE2_EXTERNALS_DIR'])
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

            externals_file = os.path.join(location, '.externals')
            if not os.path.isfile(externals_file):
                sys.stderr.write('Warning: No externals version is defined for the central release.\n'
                                 )
            else:
                env_vars['BELLE2_EXTERNALS_VERSION'] = \
                    open(externals_file).readline().strip()


def setup_local_release(location):
    """setup a local release directory"""

    setup_release(location)
    env_vars['BELLE2_LOCAL_DIR'] = location

    externals_file = os.path.join(location, '.externals')
    if not os.path.isfile(externals_file):
        sys.stderr.write('Warning: No externals version is defined for the local release.\n'
                         )
    else:
        env_vars['BELLE2_EXTERNALS_VERSION'] = \
            open(externals_file).readline().strip()


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

    for (sh_script, csh_script) in source_scripts:
        if csh:
            print 'source %s > /dev/null' % csh_script
        else:
            # cd to script directory because of geant4 setup issue with zsh
            (path, script) = os.path.split(sh_script)
            print 'SAVEOLDPWD=$OLDPWD'
            print 'SAVEPWD=$PWD'
            print 'cd %s' % path
            print 'source %s > /dev/null' % script
            print 'cd $SAVEPWD > /dev/null'
            print 'OLDPWD=$SAVEOLDPWD'
            print 'unset SAVEPWD'
            print 'unset SAVEOLDPWD'


def update_environment(release, local_release, local_dir):
    """update the environment for the given central and local release"""

    env_vars['BELLE2_EXTERNALS_VERSION'] = ''

    # add the new central release to the environment
    setup_central_release(release)

    # take care of the local release
    if local_release:
        release = local_release
        setup_local_release(local_dir)

    # export release version
    env_vars['BELLE2_RELEASE'] = release

    # setup externals
    if len(env_vars['BELLE2_EXTERNALS_VERSION']) == 0:
        sys.stderr.write('Error: No externals version is defined.\n')
        sys.exit(1)
    else:
        version = env_vars['BELLE2_EXTERNALS_VERSION']
        extdir = os.path.join(os.environ['BELLE2_EXTERNALS_TOPDIR'], version)
        if not os.path.isdir(extdir):
            extdir = os.path.join(os.environ['VO_BELLE2_SW_DIR'], 'externals',
                                  version)
            if not os.path.isdir(extdir):
                sys.stderr.write('The externals version %s does not exists.\n'
                                 % version)
                sys.exit(1)

        env_vars['BELLE2_EXTERNALS_DIR'] = extdir
        try:
            sys.path[:0] = [extdir]
            from externals import setup_externals
            setup_externals(extdir)
        except:
            sys.stderr.write('Warning: Setup of externals at %s failed.\n'
                             % extdir)

    # setup environment for the release, including the externals
    export_environment()


