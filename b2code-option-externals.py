# -*- coding: utf-8 -*-
import textwrap
from setup_tools import update_environment, SetupToolsArgumentParser

# allowed options
options = ['debug', 'opt', 'intel']


def get_argument_parser():
    description = textwrap.dedent('''
Set up the environment for selected compiler options for the externals:

  debug   : include debug symbols, no optimization
  opt     : turn on optimization (-O3), no debug symbols
  intel   : use the intel compiler

''')
    parser = SetupToolsArgumentParser(prog='b2code-option-externals',
                                      description=description,
                                      state_env_var='BELLE2_EXTERNALS_OPTION')
    parser.add_argument('option',
                        metavar='OPTION',
                        type=str,
                        choices=options,
                        help='Environment for the compiler option')
    parser.add_argument('--csh',
                        default=False,
                        action='store_true',
                        help='To be used with csh shells.')
    return parser


if __name__ == '__main__':
    args = get_argument_parser().parse_args()

    # update environment with new externals option
    update_environment(externals_option=args.option,
                       csh=args.csh)

    # inform user about successful completion
    print('echo "Environment setup for externals option: ${BELLE2_EXTERNALS_OPTION}"')
