#!/usr/bin/python
import sys, os, subprocess


# check number of arguments
if (len(sys.argv) > 2) or ((len(sys.argv) == 2) and (sys.argv[1] == '-h')):
    sys.stderr.write('Usage: setuprel [release]\n')
    sys.exit(1)


# determine which kind of shell we have
shell = subprocess.Popen(('ps -p %d -o comm=' % os.getppid()).split(), stdout=subprocess.PIPE).communicate()[0][:-1]
csh = shell in ['csh', 'tcsh']


# if the release version is given as argument take it from there
if len(sys.argv) == 2:
    release = sys.argv[1]

    # check whether it matches the release in the current directory
    if os.path.isfile('.release'):
        local_release = open('.release').readline().strip()
        
        if local_release != release:
            sys.stderr.write('Warning: The given release (%s) differs from the one in the current directory (%s). Ignoring the local version.\n' % (release, local_release))
            local_release = None
    
else:
    # check whether we are in a release directory and take the release version from there
    if not os.path.isfile('.release'):
        sys.stderr.write('Not in a release directory.\n')
        sys.exit(1)

    local_release = open('.release').readline().strip()
    release = local_release


# dictionary for new envionment variables
env_vars = {}

# helper function to take a variable from the environment or a default, and to split paths
def copy_from_environment(var, default = None):
    if os.environ.has_key(var):
        env_vars[var] = os.environ[var]
    else:
        env_vars[var] = default
    if env_vars[var] and (env_vars[var].find(':') >= 0):
        env_vars[var] = env_vars[var].split(':')

# helper function to add an entry to a path
def add_path(path, entry):
    if not env_vars.has_key(path):
        copy_from_environment(path)
        add_path(path, entry)
    elif not env_vars[path]:
        env_vars[path] = [entry]
    elif isinstance(env_vars[path], str):
        env_vars[path] = [entry, env_vars[path]]
    else:
        env_vars[path][:0] = [entry]

# helper function to remove an entry from a path
def remove_path(path, entry):
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


# define variables
unamelist = os.uname()
env_vars['BELLE2_ARCH'] = unamelist[0] + "_" + unamelist[4]
copy_from_environment('BELLE2_OPTION', 'debug')
subdir = os.path.join(env_vars['BELLE2_ARCH'], env_vars['BELLE2_OPTION'])
env_vars['BELLE2_SUBDIR'] = subdir


# function to unsetup a release directory
def unsetup_release(location):
    # externals
    remove_path('PATH', os.path.join(location, 'externals', 'bin', subdir))
    remove_path('LD_LIBRARY_PATH', os.path.join(location, 'externals', 'lib', subdir))
    # geant4
    remove_path('LD_LIBRARY_PATH', os.path.join(os.environ['G4LIB'], os.environ['G4SYSTEM']))
    remove_path('LD_LIBRARY_PATH', os.environ['CLHEP_LIB_DIR'])
    remove_path('PATH', os.path.join(os.environ['G4WORKDIR'], 'bin', os.environ['G4SYSTEM']))
    # release
    remove_path('PATH', os.path.join(location, 'bin', subdir))
    remove_path('LD_LIBRARY_PATH', os.path.join(location, 'lib', subdir))
    remove_path('PYTHON_PATH', os.path.join(location, 'lib', subdir))


# function to setup a release directory
def setup_release(location):

    # add externals directory to path and library path
    add_path('PATH', os.path.join(location, 'externals', 'bin', subdir))
    add_path('LD_LIBRARY_PATH', os.path.join(location, 'externals', 'lib', subdir))
        
    # setup geant4 environment
    geant_dir = os.path.join(location, 'externals', 'geant4')
    if csh:
        print 'source %s' % os.path.join(geant_dir, 'env.csh')
    else:
        print 'source %s' % os.path.join(geant_dir, 'env.sh')

    # set ROOTSYS
    root_dir = os.path.join(location, 'externals', 'root')
    if os.path.isdir(root_dir):
        env_vars['ROOTSYS'] = root_dir

    # add release directory to path, library path, and python path
    add_path('PATH', os.path.join(location, 'bin', subdir))
    add_path('LD_LIBRARY_PATH', os.path.join(location, 'lib', subdir))
    add_path('PYTHON_PATH', os.path.join(location, 'lib', subdir))


# remove path settings from old release
if os.environ.has_key('BELLE2_RELEASE_DIR'):
    unsetup_release(os.environ['BELLE2_RELEASE_DIR'])
if os.environ.has_key('BELLE2_LOCAL_DIR'):
    unsetup_release(os.environ['BELLE2_LOCAL_DIR'])


# setup the central release if it exists
location = os.path.join(os.environ['VO_BELLE2_SW_DIR'], 'release', release)
if release != 'head':
    if not os.path.isdir(location):
        sys.stderr.write('Warning: No central release %s found.\n' % release)
        release = None

    else:
        setup_release(location)
        env_vars['BELLE2_RELEASE_DIR'] = location


# take care of local release
location = os.getcwd()
if local_release:
    release = local_release
    setup_release(location)
    env_vars['BELLE2_LOCAL_DIR'] = location


# export release version
env_vars['BELLE2_RELEASE'] = release


# generate shell commands for environment settings
for var in env_vars.keys():
    value = env_vars[var]
    if isinstance(value, list):
        value = ':'.join(value)
    if csh:
        print('setenv %s %s' % (var, value))
    else:
        print('export %s=%s' % (var, value))

