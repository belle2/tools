#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function
import os
import sys

# The maximal file size in bytes
limit = 1024 * 1024

# Exceptions
exceptions = [
    'analysis/data/TMVA/StandardPi0/weights/PI0-MC3.5_1_vs_0_LPCA.class.C',
    'mdst/tests/mdst_compatibility.out',
    'geometry/data/MagneticField3d_TotalVolume-150302-01-04_cylindrical.dat.gz',
    'geometry/data/MagneticField3d_TrackingVolume-150302-01-05_cylindrical.dat.gz',
    'cdc/data/xt_',
    'generators/modules/cryinput/data/cosmics_',
    'tracking/data/',
    'reconstruction/data'
    ]

# loop over to be committed files
os.chdir(sys.argv[1])
fail = False
for root, dirs, files in os.walk('.'):
    for changed_file in files:
        file_name = os.path.join(root, changed_file)[2:]
        skip = False
        for exception in exceptions:
            if file_name.startswith(exception):
                skip = True
                break
        if skip:
            continue
        if os.path.getsize(file_name) > limit:
            print('file size limit exceeded for %s' % file_name)
            fail = True
            
# print instructions in case of failed test
if fail:
    print('=> Contact the git repository administrator (Thomas.Kuhr@lmu.de) if you are convinced that these files should nevertheless be stored in the code repository.')
    sys.exit(1)
