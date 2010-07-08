#!/bin/bash

# prepare directory for source code of tools
DIR=`pwd`
mkdir src

# astyle
cd ${DIR}/src
svn co -r56 https://astyle.svn.sourceforge.net/svnroot/astyle/tags/1.23/AStyle astyle
cd astyle/build/gcc
make
cp bin/astyle ${DIR}

# scons
cd ${DIR}/src
svn co --username guest --password guest --non-interactive -r4725 http://scons.tigris.org/svn/scons/tags/1.3.0 scons
cd scons
python bootstrap.py build/scons
cd build/scons
python setup.py install --no-version-script --install-scripts=${DIR} --install-data=${DIR}/share --install-lib=${DIR}/lib
