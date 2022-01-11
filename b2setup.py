# -*- coding: utf-8 -*-
import sys
import os
import textwrap
import argparse
from setup_tools import get_var, update_environment, SetupToolsArgumentParser
from versioning import supported_release


class ListReleasesHelpAction(argparse.Action):
    """
    List all available releases in addition to printing normal help. Then exit.
    """

    def __call__(self, parser, args, values, option_string=None):
        parser.print_help()
        releases = []
        releases_topdir = os.path.join(os.environ['VO_BELLE2_SW_DIR'], 'releases')
        if os.path.isdir(releases_topdir):
            for entry in os.listdir(releases_topdir):
                if entry.find('.') < 0 and not os.path.isfile(entry):
                    releases.append(entry)

        if len(releases) > 0:
            sys.stderr.write('\n  The following releases are available:\n')
            for rel in releases:
                sys.stderr.write('    %s\n' % rel)
        else:
            sys.stderr.write('\n  There are no central releases available.\n')
        sys.stderr.write('\n')
        sys.exit(0)


def get_argument_parser():
    description = textwrap.dedent('''\n
    This command sets up the environment for a central or local release
    of the Belle II software or for an Belle II analysis.

    -> Central release setup:

      Execute the b2setup command with the central release version as argument.

    -> Local release setup:

      Execute the b2setup command in the local release directory.

    -> Analysis setup:

      Execute the b2setup command in the local analysis directory.
    ''')

    too_many_arguments_message = textwrap.dedent('''\n

    Note: When running b2setup inside a script without any argument, the arguments given to the containing script will be forwarded to b2setup automatically. To avoid this, please use

    b2setup ""

    ''')

    parser = SetupToolsArgumentParser(prog='b2setup',
                                      error_message=too_many_arguments_message,
                                      add_help=False,
                                      description=description)
    parser.add_argument('release',
                        metavar='RELEASE',
                        type=str,
                        nargs='?',
                        default=os.environ.get('MY_BELLE2_RELEASE'))
    parser.add_argument('--csh',
                        default=False,
                        action='store_true',
                        help='To be used with csh shells.')
    parser.add_argument('--help', '-h', '-?',
                        nargs=0,
                        action=ListReleasesHelpAction)
    return parser


if __name__ == '__main__':

    # if the MY_BELLE2_DIR environment variable is set use it as local release directory
    if 'MY_BELLE2_DIR' in os.environ:
        os.chdir(os.environ['MY_BELLE2_DIR'])

    # Get parser and arguments
    args = get_argument_parser().parse_args()
    release = args.release

    # determine local/analysis directory by looking for .externals or .analysis file in current and parent directories
    local_dir = None
    if release is None:
        local_dir = os.path.abspath(os.getcwd())
        while len(local_dir) > 1 and not (os.path.isfile(os.path.join(local_dir, '.analysis'))
                                          or os.path.isfile(os.path.join(local_dir, '.externals'))):
            local_dir = os.path.dirname(local_dir)
        if os.path.isfile(os.path.join(local_dir, '.analysis')):
            release = open(os.path.join(local_dir, '.analysis')).readline().strip()
        if len(local_dir) <= 1:
            local_dir = None

    # check that at least one of central release and local/analysis is given
    if not release and not local_dir:
        sys.stderr.write('Error: Neither in a development or analysis directory nor a release specified.\n')
        sys.exit(1)

    # check whether the central release exists
    if release and not os.path.isdir(os.path.join(os.environ['VO_BELLE2_SW_DIR'], 'releases', release)):
        sys.stderr.write('Error: No central release %s found.\n' % release)
        sys.exit(1)

    # setup environment for release
    update_environment(release, local_dir, csh=args.csh)

    # inform user about successful completion
    if release and local_dir:
        print('echo "Environment setup for analysis : ${BELLE2_ANALYSIS_DIR}"')
        print('echo "Central release directory      : ${BELLE2_RELEASE_DIR}"')
    else:
        if len(get_var('BELLE2_RELEASE')) > 0:
            print('echo "Environment setup for release: ${BELLE2_RELEASE}"')
        if len(get_var('BELLE2_RELEASE_DIR')) > 0:
            print('echo "Central release directory    : ${BELLE2_RELEASE_DIR}"')
        if len(get_var('BELLE2_LOCAL_DIR')) > 0:
            print('echo "Local development directory  : ${BELLE2_LOCAL_DIR}"')
        if len(get_var('BELLE2_ANALYSIS_DIR')) > 0:
            print('echo "Analysis directory           : ${BELLE2_ANALYSIS_DIR}"')

    # set the build option if a .option file exists in the analysis or development directory
    if local_dir and os.path.isfile(os.path.join(local_dir, '.option')):
        build_option = open(os.path.join(local_dir, '.option')).readline().strip()
        print('b2code-option %s' % build_option)

    # check SConstruct is a symlink to site_scons/SConstruct
    if local_dir:
        sconstruct = os.path.join(local_dir, 'SConstruct')
        target = os.path.realpath(os.path.join(local_dir, 'site_scons', 'SConstruct'))
        if not os.path.islink(sconstruct) or os.path.realpath(sconstruct) != target:
            sys.stderr.write(
                'Error: "SConstruct" should be a symbolic link to site_scons/SConstruct, but it doesn\'t exist or is a copy or points to the wrong location.\n')
            sys.stderr.write('Please recreate the link with\n')
            sys.stderr.write(' ln -sf site_scons/SConstruct .\n')
        # for analyses check site_scons is a symlink to the release site_scons
        if release:
            site_scons = os.path.join(local_dir, 'site_scons')
            release_dir = os.path.join(os.environ['VO_BELLE2_SW_DIR'], 'releases', release)
            target = os.path.realpath(os.path.join(release_dir, 'site_scons'))
            if not os.path.islink(site_scons) or os.path.realpath(site_scons) != target:
                sys.stderr.write(
                    'Error: "site_scons" should be a symbolic link to %s/site_scons, but it doesn\'t exist or is a copy or points to the wrong location.\n' % release_dir)
                sys.stderr.write('Please recreate the link with\n')
                sys.stderr.write(' ln -sf %s/site_scons .\n' % release_dir)
        else:
            # for development directories check .git/hooks is a link to ${BELLE2_TOOLS}/hooks
            hooks = os.path.join(local_dir, '.git/hooks')
            target = os.path.realpath(os.path.join(os.environ['BELLE2_TOOLS'], 'hooks'))
            if not os.path.islink(hooks) or os.path.realpath(hooks) != target:
                sys.stderr.write(
                    'Warning: ".git/hooks" should be a symbolic link to ${BELLE2_TOOLS}/hooks, but it doesn\'t exist or is a copy or points to the wrong location.\n')
                sys.stderr.write('Please recreate the link with\n')
                sys.stderr.write(' rm -rf ' + hooks + ' && ln -sf ${BELLE2_TOOLS}/hooks ' + hooks + '\n')

    # check the externals and warn the user if the check fails
    extdir = get_var('BELLE2_EXTERNALS_DIR')
    try:
        sys.path[:0] = [extdir]
        from externals import check_externals

        if not check_externals(extdir):
            sys.stderr.write('Error: Check of externals at %s failed.\n' % extdir)
    except:
        sys.stderr.write('Error: Check of externals at %s failed.\n' % extdir)

    # check whether the central release is supported
    if release is not None:
        supported = supported_release(release)
        if supported != release:
            print(
                'echo "Warning: The release %s is not supported any more. Please update to %s"' % (release, supported))
