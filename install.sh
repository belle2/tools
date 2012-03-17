#!/bin/bash

# prepare directory for source code of tools
DIR=`python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $(dirname $0)`
if [ ! -d ${DIR}/src ]; then
  mkdir ${DIR}/src
fi

# astyle
if [ ! -f ${DIR}/astyle ]; then
  cd ${DIR}/src
  svn export -r321 https://astyle.svn.sourceforge.net/svnroot/astyle/tags/2.02/AStyle astyle
  if [ `uname`=Darwin ]; then
    cd astyle/build/mac
  else
    cat astyle/src/ASLocalizer.cpp | sed "1c/\*" > ASLocalizer.cpp
    mv ASLocalizer.cpp astyle/src/
    cd astyle/build/gcc
  fi
  make
  cp bin/astyle ${DIR}
fi

# scons
if [ ! -f ${DIR}/scons ]; then
  cd ${DIR}/src
  svn export --username guest --password guest --non-interactive -r4725 http://scons.tigris.org/svn/scons/tags/1.3.0 scons
  cd scons
  python bootstrap.py build/scons
  cd build/scons
  python setup.py install --no-version-script --install-scripts=${DIR} --install-data=${DIR}/share --install-lib=${DIR}/lib
fi
