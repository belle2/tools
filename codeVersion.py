#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import os
import pysvn

# check number of arguments
if len(sys.argv) != 2:
    print 'file name argument missing'
    sys.exit(1)

# check whether the file exists
filename = sys.argv[1]
if not os.access(filename, os.R_OK):
    print 'undefined'
    sys.exit()

# check whether it is versioned in svn
svn = pysvn.Client()
status = svn.status(filename)[0]
if status.text_status == pysvn.wc_status_kind.unversioned:
    print 'undefined'
    sys.exit()

# get release, tag, or revision number
entry = status.entry
url = entry.url.split('/')
if url[3] == 'releases':
    version = url[4]
elif url[4] == 'tags':
    version = 'tag ' + url[5]
else:
    version = 'revision %d' % entry.revision.number

# check whether the file was modified
if status.text_status != pysvn.wc_status_kind.normal:
    version = 'modified ' + version

# print the result
print version
