#!/usr/bin/env python3
# -*- coding: utf-8 -*-


import os
import sys
import subprocess

# Go to temporary directory
os.chdir(sys.argv[1])

# Get committer
committer = os.environ['BELLE2_USER']

# Determine librarians and authors
access = {}
subprocess.call(['tar', '-xf', 'access.tar'])
for root, dirs, files in os.walk('access'):
    for access_file in files:
        file_name = os.path.join(root, access_file)
        dir_name = os.path.dirname(file_name.split(os.path.sep, 1)[1])
        if file_name.endswith('.librarians'):
            index = 0
        elif file_name.endswith('.authors'):
            index = 1
        else:
            continue
        if dir_name not in list(access.keys()):
            parent_dir = dir_name.split(os.path.sep, -1)[0]
            if parent_dir in list(access.keys()):
                access[dir_name] = [list(access[parent_dir][0]), list(access[parent_dir][1])]
            else:
                access[dir_name] = [[], []]
        for line in open(file_name).readlines():
            line = line[:-1].split('#')[0].strip()
            if len(line) > 0:
                access[dir_name][index].append(line)
subprocess.call(['rm', '-rf', 'access.tar', 'access'])

# loop over to be committed files
failed_access = []
failed_dirs = []
for root, dirs, files in os.walk('.'):
    for changed_file in files:
        file_name = os.path.join(root, changed_file)[2:]
        file_name.replace('.deleted', '')
        dir_name = os.path.dirname(file_name)
        while dir_name != '' and dir_name not in list(access.keys()):
            dir_name = os.path.dirname(dir_name)
        librarians, authors = access.get(dir_name, [[], []])
        if dir_name == '':
            dir_name = '[ROOT]'
        if len(librarians) == 0 and os.environ.get('STASH_IS_ADMIN', 'false') == 'true':
            librarians = [committer]
        if (file_name.endswith('/.librarians') or file_name.endswith('/.authors')) and committer not in librarians:
            failed_access.append(os.path.dirname(file_name))
        elif (committer not in librarians + authors) and ('*' not in authors):
            failed_dirs.append(dir_name)

# return result of access check
if len(failed_access) > 0:
    print(("\nYou (%s) don't have the right to edit the list of librarians or authors of the following directories:" % committer))
    for failed_dir in list(set(failed_access)):
        print((' %s' % failed_dir))
if len(failed_dirs) > 0:
    print(("\nYou (%s) don't have the right to commit code to the following directories:" % committer))
    for failed_dir in list(set(failed_dirs)):
        print((' %s' % failed_dir))
if len(failed_access + failed_dirs) > 0:
    sys.exit(1)
