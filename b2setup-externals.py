# -*- coding: utf-8 -*-
from __future__ import print_function
import sys
import os
import textwrap
from setup_tools import get_var, update_environment, SetupToolsArgumentParser


def get_argument_parser(available=None, default=None):
    description = textwrap.dedent('''\n
    This command sets up the Belle II externals to be used without any specific release
    of the Belle II software. It's useful if you just want to enable the software
    included in the Belle II externals like an updated ROOT or git version. Without an
    argument it will setup the latest version it can find, otherwise it will setup
    the specified version
    ''')

    parser = SetupToolsArgumentParser(prog='b2setup-externals',
                                      error_message="You can try installing unavailable versions by using 'b2install-externals VERSION'",
                                      description=description)
    parser.add_argument('release',
                        metavar='RELEASE',
                        type=str,
                        default=default,
                        choices=available,
                        nargs='?')
    parser.add_argument('--csh',
                        default=False,
                        action='store_true',
                        help='To be used with csh shells.')

    return parser


if __name__ == '__main__':

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

    if available_versions:
        print(textwrap.dedent("""
        Available Versions: %s
        Default Version: %s""" % (", ".join(available_versions), default_version)), file=sys.stderr)

    if not available_versions:
        print(textwrap.dedent("""
        Error: Cannot find any externals in the top directory '%s'.
        Try installing externals with b2install-externals first""" % top_dir), file=sys.stderr)
        sys.exit(1)

    # check that no Belle II software is set up
    if 'BELLE2_RELEASE' in os.environ.keys() or 'BELLE2_LOCAL_DIR' in os.environ.keys():
        print('Error: This command can only be used if no Belle II software is set up.', file=sys.stderr)
        sys.exit(1)

    args = get_argument_parser(available=available_versions, default=default_version).parse_args()

    # setup externals
    update_environment(externals_version=args.version, csh=args.csh)

    try:
        extdir = get_var('BELLE2_EXTERNALS_DIR')
        sys.path[:0] = [extdir]
        from externals import check_externals

        if not check_externals(extdir):
            sys.stderr.write('Error: Check of externals at %s failed.\n' % extdir)
    except:
        sys.stderr.write('Error: Check of externals at %s failed.\n' % extdir)
