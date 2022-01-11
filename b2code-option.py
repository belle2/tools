# -*- coding: utf-8 -*-
from __future__ import print_function
import textwrap
from setup_tools import update_environment, SetupToolsArgumentParser

# Allowed options
options = ['debug', 'opt', 'intel', 'clang']


def get_argument_parser():

    description = textwrap.dedent('''\n
    Set up the environment for selected compiler options:

      debug : use gcc compiler, include debug symbols, no optimization
      opt   : use gcc compiler, no debug symbols, turn on -O3 optimization
      intel : use intel compiler, no debug symbols
      clang : use clang compiler (LLVM), no debug symbols, turn on -O3 optimization
    ''')
    parser = SetupToolsArgumentParser(prog='b2code-option',
                                      description=description,
                                      state_env_var='BELLE2_OPTION')
    parser.add_argument('option',
                        metavar='OPTION',
                        type=str,
                        choices=options,
                        help='Environment for the compiler option.')
    parser.add_argument('--csh',
                        default=False,
                        action='store_true',
                        help='To be used with csh shells.')
    return parser


if __name__ == '__main__':
    args = get_argument_parser().parse_args()

    # Update the environment with the new option.
    update_environment(option=args.option,
                       csh=args.csh)

    # Inform the user about successful completion.
    print('echo "Environment setup for build option: ${BELLE2_OPTION}"')
