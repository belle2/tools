#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys
import subprocess

# loop over to be committed files
os.chdir(sys.argv[1])
failed_files = []
for root, dirs, files in os.walk('.'):
    for changed_file in files:
        file_name = os.path.join(root, changed_file)[2:]
        if os.path.splitext(file_name)[1] in ['.h', '.cc', '.py']:
            if subprocess.call(['b2code-style-check', file_name], stdout=open(os.devnull, 'w'), stderr=open(os.devnull, 'w')) != 0:
                failed_files.append(file_name)

# print instructions in case of failed test
if len(failed_files) > 0:
    print('\nThe following files do not comply with the style rules:')
    for failed_file in failed_files:
        print((' %s' % failed_file))
    print("=> Run the 'b2code-style-fix' tool on the files listed above and 'git add' them to your commit again.")
    print("   (And make sure you have the latest version in your tools directory.)")
    sys.exit(1)
