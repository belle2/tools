# -*- coding: utf-8 -*-
import sys
import os
import subprocess
import argparse
from distutils.version import LooseVersion

try:
    from importlib import reload
except ImportError:
    pass

# determine library path environment variable
lib_path_name = 'LD_LIBRARY_PATH'
if os.uname()[0] == 'Darwin':
    lib_path_name = 'DYLD_LIBRARY_PATH'

# dictionary for environment variables
env_vars = {}

# list of [sh, csh] scripts that should be sourced
source_scripts = []

class NoExitHelpAction(argparse.Action):
    """
    Don't exit when help is needed. Also sets args.help = True. This is used by some scripts to
    provide additional info after giving the argparse help.
    """

    def __call__(self, parser, namespace, values, option_string=None):
        parser.print_help()
        setattr(namespace, self.dest, True)

class SetupToolsArgumentParser(argparse.ArgumentParser):

    def __init__(self,
                 state_env_var=None, 
                 error_message=None,
                 *args,
                 **kwargs):
        super(SetupToolsArgumentParser, self).__init__(*args, **kwargs)
        self.formatter_class = argparse.RawDescriptionHelpFormatter
        self.state_env_var = state_env_var 
        self.error_message = error_message

    def error(self, message):
        """
        Allows printing the state of an environment variable variable or and extra message when exiting with error.
        """
        self.print_usage(sys.stderr)
        args = {'prog': self.prog, 'message': message}
        self._print_message('%(prog)s: error: %(message)s\n' % args, sys.stderr)
        if self.state_env_var:
            sys.stderr.write('The current option is {}.\n'.format(os.environ.get(self.state_env_var, '')))
        if self.error_message:
            sys.stderr.write(self.error_message)
        sys.exit(2)

    def print_help(self, file=None):
        """
        Adapted so help goes to stderr and doesn't confuse shell wrapper.
        """
        self._print_message(self.format_help(), sys.stderr)


def set_var(var, value):
    env_vars[var] = value
    os.environ[var] = value
    if len(value) == 0:
        del os.environ[var]


def get_var(var):
    return env_vars.get(var, '')


def copy_from_environment(var, default=None):
    """helper function to take a variable from the environment or a default, and to split paths"""

    env_vars[var] = os.environ.get(var, default)
    if env_vars[var] and env_vars[var].find(':') >= 0:
        env_vars[var] = env_vars[var].split(':')


def add_path(path, entry):
    """helper function to add an entry to a path"""

    if path not in env_vars:
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

    if path not in env_vars:
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

    if var not in env_vars:
        env_vars[var] = os.environ.get(var, '')
    env_vars[var] = (env_vars[var] + ' ' + option).strip()


def remove_option(var, option):
    """helper function to remove an option from a variable"""

    if var not in env_vars:
        if var in os.environ:
            env_vars[var] = os.environ[var]
        else:
            return
    env_vars[var] = env_vars[var].replace(' ' + option, '').replace(option, '').strip()


def export_environment(csh=False):
    """generate shell commands for environment settings"""

    for var in env_vars.keys():
        value = env_vars[var]
        if isinstance(value, list):
            value = ':'.join(value)
        if value and len(value) > 0:
            if csh:
                print('setenv %s "%s"' % (var, value))
            else:
                print('export %s="%s"' % (var, value))
        else:
            if csh:
                print('unsetenv %s' % var)
            else:
                print('unset %s' % var)

    for (sh_script, csh_script) in source_scripts:
        if csh:
            # cd to script directory because of geant4 setup issue with csh
            (path, script) = os.path.split(csh_script)
            print('set SAVEOLDPWD=$owd')
            print('set SAVEPWD=$PWD')
            print('cd %s' % path)
            print('source ./%s > /dev/null' % script)
            print('cd $SAVEPWD > /dev/null')
            print('set owd=$SAVEOLDPWD')
            print('unset SAVEPWD')
            print('unset SAVEOLDPWD')
        else:
            # cd to script directory because of geant4 setup issue with zsh
            (path, script) = os.path.split(sh_script)
            print('SAVEOLDPWD=$OLDPWD')
            print('SAVEPWD=$PWD')
            print('cd %s' % path)
            print('source ./%s > /dev/null' % script)
            print('cd $SAVEPWD > /dev/null')
            print('OLDPWD=$SAVEOLDPWD')
            print('unset SAVEPWD')
            print('unset SAVEOLDPWD')

    try:
        if LooseVersion('.'.join(env_vars['BELLE2_EXTERNALS_VERSION'][1:].split('-'))) >= '01.10.00':
            # overwrite JUPYTER config directory to fix bug in ROOT v6.24
            try:
                value = os.path.join(os.environ['HOME'], '.jupyter')
                if csh:
                    print('setenv JUPYTER_CONFIG_DIR "%s"' % value)
                else:
                    print('export JUPYTER_CONFIG_DIR="%s"' % value)
            except KeyError:
                print(
                    'echo "Info: HOME environment variable is not set, therefore can not set '
                    'JUPYTER_CONFIG_DIR to \\$HOME/.jupyter."'
                )
    except:
        pass


def unsetup_release(location):
    """function to unsetup a release directory"""

    subdir = os.environ['BELLE2_SUBDIR']

    # remove release directory to path, library path, and python path
    remove_path('PATH', os.path.join(location, 'bin', subdir))
    remove_path(lib_path_name, os.path.join(location, 'lib', subdir))
    remove_path('PYTHONPATH', os.path.join(location, 'lib', subdir))
    # for root6, add both the location and the include folder, otherwise
    # ROOT's header lookup might perform a fallback to the headers at the
    # compile location
    remove_path('ROOT_INCLUDE_PATH', location)
    remove_path('ROOT_INCLUDE_PATH', os.path.join(location, 'include'))


def setup_release(location):
    """function to setup a release directory"""

    subdir = os.environ['BELLE2_SUBDIR']

    # add release directory to path, library path, and python path
    add_path('PATH', os.path.join(location, 'bin', subdir))
    add_path(lib_path_name, os.path.join(location, 'lib', subdir))
    add_path('PYTHONPATH', os.path.join(location, 'lib', subdir))
    # for root6, add both the location and the include folder, otherwise
    # ROOT's header lookup might perform a fallback to the headers at the
    # compile location
    add_path('ROOT_INCLUDE_PATH', location)
    add_path('ROOT_INCLUDE_PATH', os.path.join(location, 'include'))

    externals_file = os.path.join(location, '.externals')
    if os.path.isfile(externals_file):
        env_vars['BELLE2_EXTERNALS_VERSION'] = open(externals_file).readline().strip()


def update_environment(release=None, local_dir=None, externals_version=None, option=None, externals_option=None, csh=False):
    """update the environment for the given central and local release or analysis and options"""

    # no change of release and local_dir if are both None (only change of options)
    if release is None and local_dir is None:
        release = os.environ.get('BELLE2_RELEASE_DIR', None)
        local_dir = os.environ.get('BELLE2_ANALYSIS_DIR', os.environ.get('BELLE2_LOCAL_DIR', None))

    # remove old central release and local/analysis
    for var in ['BELLE2_RELEASE_DIR', 'BELLE2_LOCAL_DIR', 'BELLE2_ANALYSIS_DIR']:
        if var in os.environ:
            unsetup_release(os.environ[var])
            env_vars[var] = ''
    env_vars['BELLE2_RELEASE'] = ''

    # remove old externals
    if 'BELLE2_EXTERNALS_DIR' in os.environ:
        try:
            sys.path[:0] = [os.environ['BELLE2_EXTERNALS_DIR']]
            from externals import unsetup_externals
            unsetup_externals(os.environ['BELLE2_EXTERNALS_DIR'])
        except BaseException:
            sys.stderr.write('Warning: Unsetup of externals at %s failed.\n'
                             % os.environ['BELLE2_EXTERNALS_DIR'])
        env_vars['BELLE2_EXTERNALS_DIR'] = ''

    # use explicit externals version if given
    if externals_version is not None:
        env_vars['BELLE2_EXTERNALS_VERSION'] = externals_version
    elif release or local_dir:
        env_vars['BELLE2_EXTERNALS_VERSION'] = ''
    else:
        env_vars['BELLE2_EXTERNALS_VERSION'] = os.environ['BELLE2_EXTERNALS_VERSION']

    # set build option if given
    if option:
        set_var('BELLE2_OPTION', option)
        set_var('BELLE2_SUBDIR', os.path.join(os.environ.get('BELLE2_ARCH'), option))

    # set externals build option if given
    if externals_option:
        set_var('BELLE2_EXTERNALS_OPTION', externals_option)
        set_var('BELLE2_EXTERNALS_SUBDIR', os.path.join(os.environ.get('BELLE2_ARCH'), externals_option))

    # add the new central release to the environment
    if release:
        location = os.path.join(os.environ['VO_BELLE2_SW_DIR'], 'releases', release)
        setup_release(location)
        env_vars['BELLE2_RELEASE_DIR'] = location
        env_vars['BELLE2_RELEASE'] = release

    # take care of the local release or analysis
    if local_dir:
        setup_release(local_dir)
        if release:
            env_vars['BELLE2_ANALYSIS_DIR'] = local_dir
        else:
            env_vars['BELLE2_LOCAL_DIR'] = local_dir

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
                sys.stderr.write('The externals version %s does not exist. '
                                 'You can use \'b2install-externals\' to install them.\n'
                                 % version)
                sys.exit(1)

        env_vars['BELLE2_EXTERNALS_DIR'] = extdir
        try:
            sys.path[:0] = [extdir]
            import externals
            # previously we may have imported unsetup_externals() from the old version,
            # force reload of module from new file here
            reload(externals)
            externals.setup_externals(extdir)
        except BaseException:
            sys.stderr.write('Error: Setup of externals at %s failed.\n'
                             % extdir)
            raise

    # setup environment for the release, including the externals
    export_environment(csh=csh)
