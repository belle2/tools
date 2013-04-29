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
  if [ "$?" != "0" ]; then
    wget -O - --user=belle2 --password=Aith4tee https://belle2.cc.kek.jp/download/astyle_2.02.tgz | tar xz
  fi
  if [ `uname` = Darwin ]; then
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
  wget -O - --tries=3 http://downloads.sourceforge.net/project/scons/scons/2.2.0/scons-2.2.0.tar.gz | tar xz
  if [ "$?" != "0" ]; then
    wget -O - --user=belle2 --password=Aith4tee https://belle2.cc.kek.jp/download/scons-2.2.0.tar.gz | tar xz
  fi
  mv scons-2.2.0 scons
  cd scons
  python setup.py install --no-version-script --install-scripts=${DIR} --install-data=${DIR}/share --install-lib=${DIR}/lib
fi

# gcc
if [ ! -d ${DIR}/gcc ]; then
  cd ${DIR}/src
  wget -O - --tries=3 --no-check-certificate --user=belle2 --password=Aith4tee https://belle2.cc.kek.jp/download/gcc-4.7.3-contrib.tgz | tar xz
  cd gcc
  mkdir -p build
  cd build
  ../src/configure --disable-multilib --prefix=${DIR}/gcc --enable-languages=c,c++,fortran 
  NPROCESSES=`grep "physical id.*0" /proc/cpuinfo 2> /dev/null | wc -l`
  if [ "${NPROCESSES}" = "0" ]; then
    NPROCESSES=`grep processor /proc/cpuinfo 2> /dev/null | wc -l`
    if [ "${NPROCESSES}" = "0" ]; then
      NPROCESSES=1
    fi
  fi
  make -j ${NPROCESSES}
  make install
fi
