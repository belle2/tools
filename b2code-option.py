# -*- coding: utf-8 -*-
import sys
import os
import argparse
import textwrap
from setup_tools import update_environment

# Allowed options
options = ['debug', 'opt', 'intel', 'clang']


def arg_parser():

    description = textwrap.dedent('''\n
Set up the environment for selected compiler options:

  debug : use gcc compiler, include debug symbols, no optimization
  opt   : use gcc compiler, no debug symbols, turn on -O3 optimization
  intel : use intel compiler, no debug symbols
  clang : use clang compiler (LLVM), no debug symbols, turn on -O3 optimization
''')
    parser = argparse.ArgumentParser(prog='b2code-option',
                                     description=description,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('option',
                        metavar='OPTION',
                        type=str,
                        help='Environment for the compiler option: {}'.format('|'.join(options)))
    parser.add_argument('--csh',
                        default=False,
                        action='store_true',
                        help='To be used with csh shells.')
    return parser


if __name__ == '__main__':

    args = arg_parser().parse_args()

    if args.option not in options:
        sys.stderr.write('The chosen option ({}) is not available.\n'.format(args.option))
        sys.stderr.write('The current option is {}.\n'.format(os.environ.get('BELLE2_OPTION', '')))
        sys.exit(1)

    # Update the environment with the new option.
    update_environment(option=args.option,
                       csh=args.csh)

    # Inform the user about successful completion.
    print('echo "Environment setup for build option: ${BELLE2_OPTION}"')
