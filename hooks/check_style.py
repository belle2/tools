#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function
import os
import sys
import subprocess

# Exceptions
exceptions = []

# loop over to be committed files
os.chdir(sys.argv[1])
failed_files = []
for root, dirs, files in os.walk('.'):
    for changed_file in files:
        file_name = os.path.join(root, changed_file)[2:]
        if len([exception for exception in exceptions if file_name.startswith(exception)]) > 0:
            continue
        if os.path.splitext(file_name)[1] in ['.h', '.cc', '.py']:
            if subprocess.call(['checkstyle', file_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE) != 0:
                failed_files.append(file_name)
            
# print instructions in case of failed test
if len(failed_files) > 0:
    print('\nThe following files do not comply with the style rules:')
    for failed_file in failed_files:
        print(' %s' % failed_file)
    print("=> Run the 'fixstyle' tool on the files listed above and 'git add' them to your commit again.")
    print("   (And make sure you have the latest version in your $BELLE2_TOOLS directory.)")
    sys.exit(1)
