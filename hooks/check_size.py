#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function
import os
import sys

# The maximal file size in bytes
limit = 1024 * 1024

# Exceptions
exceptions = {}

# loop over to be committed files
os.chdir(sys.argv[1])
failed_files = []
for root, dirs, files in os.walk('.'):
    for changed_file in files:
        file_name = os.path.join(root, changed_file)[2:]
        file_limit = exceptions.get(file_name, limit)
        if os.path.getsize(file_name) > file_limit:
            failed_files.append(file_name)
            
# print instructions in case of failed test
if len(failed_files) > 0:
    print('\nThe following files exceed the maximally allowed file size:')
    for failed_file in failed_files:
        print(' %s' % failed_file)
    print('=> Contact the git repository administrator (Thomas.Kuhr@lmu.de) if you are convinced that these files should nevertheless be stored in the code repository.')
    sys.exit(1)
