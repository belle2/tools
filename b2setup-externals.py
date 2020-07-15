# -*- coding: utf-8 -*-
import sys
import os
import glob
from setup_tools import get_var, update_environment

using_csh = False
if len(sys.argv)>1 and sys.argv[1] == '--csh':
    using_csh = True
    del sys.argv[1]

# prepare list of available versions
top_dir = os.environ["BELLE2_EXTERNALS_TOPDIR"]
# get sorted list of directories in externals directory
try:
    available_versions = sorted(next(os.walk(top_dir))[1])
except:
    available_versions = []

# and chose the latest one as default
if available_versions:
    default_version = available_versions[-1]
else:
    default_version = None

# check for help option
if len(sys.argv) >= 2 and sys.argv[1] in ['--help', '-h', '-?']:
    print >> sys.stderr, """
Usage: b2setup-externals [externals_version]

This command sets up the Belle II externals to be used without any specific release
of the Belle II software. It's useful if you just want to enable the software
included in the Belle II externals like an updated ROOT or git version. Without an
argument it will setup the latest version it can find, otherwise it will setup
the specified version"""
    if available_versions:
        print >> sys.stderr, """
Available Versions: %s
Default Version: %s""" % (", ".join(available_versions), default_version)
        sys.exit(0)

if not available_versions:
    print >> sys.stderr, """
Error: Cannot find any externals in the top directory '%s'.
Try installing externals with b2install-externals first""" % top_dir
    sys.exit(1)

# check number of arguments
if len(sys.argv) > 2:
    print >> sys.stderr, 'Usage: b2setup-externals [--help] [version]'
    sys.exit(1)

# check that no Belle II software is set up
if 'BELLE2_RELEASE' in os.environ.keys() or 'BELLE2_LOCAL_DIR' in os.environ.keys():
    print >> sys.stderr, 'Error: This command can only be used of no Belle II software is set up.'
    sys.exit(1)

# check which version we want
version = default_version
if len(sys.argv) == 2:
    version = sys.argv[1]
    if version not in available_versions:
        print >> sys.stderr, """
Error: Externals version '{0}' is not available, available versions are {1}.\n
You can try installing it by using 'b2install-externals {0}'""".format(version, ", ".join(available_versions))

        sys.exit(1)

# setup externals
update_environment(externals_version=version, csh=using_csh)

try:
    extdir = get_var('BELLE2_EXTERNALS_DIR')
    sys.path[:0] = [extdir]
    from externals import check_externals
    if not check_externals(extdir):
        sys.stderr.write('Error: Check of externals at %s failed.\n' % extdir)
except:
    sys.stderr.write('Error: Check of externals at %s failed.\n' % extdir)
