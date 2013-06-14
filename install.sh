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

# determine number of cores
NPROCESSES=`grep "physical id.*0" /proc/cpuinfo 2> /dev/null | wc -l`
if [ "${NPROCESSES}" = "0" ]; then
  NPROCESSES=`grep processor /proc/cpuinfo 2> /dev/null | wc -l`
  if [ "${NPROCESSES}" = "0" ]; then
    NPROCESSES=1
  fi
fi

# binutils
if [ ! -d ${DIR}/binutils ]; then
  cd ${DIR}/src
  if [ ! -d ${DIR}/src/binutils/src ]; then
    wget -O - --tries=3 http://ftp.gnu.org/gnu/binutils/binutils-2.23.1.tar.gz | tar xz
    if [ "$?" != "0" ]; then
      wget -O - --user=belle2 --password=Aith4tee https://belle2.cc.kek.jp/download/binutils-2.23.1.tar.gz | tar xz
    fi
    mkdir binutils
    mv binutils-2.23.1 binutils/src
  fi
  mkdir -p binutils/build
  cd binutils/build
  ../src/configure --disable-multilib --with-sysroot --enable-shared --prefix=${DIR}/binutils
  make -j ${NPROCESSES}
  make install
fi

export PATH=${DIR}/binutils/bin:${PATH}
if [ -n "${LD_LIBRARY_PATH}" ]; then
  export LD_LIBRARY_PATH=${DIR}/binutils/lib:${DIR}/binutils/lib64:${LD_LIBRARY_PATH}
else
  export LD_LIBRARY_PATH=${DIR}/binutils/lib:${DIR}/binutils/lib64
fi

# gcc
if [ ! -d ${DIR}/gcc ]; then
  cd ${DIR}/src
  if [ ! -d ${DIR}/src/gcc/src ]; then
    wget -O - --tries=3 --no-check-certificate --user=belle2 --password=Aith4tee https://belle2.cc.kek.jp/download/gcc-4.7.3-contrib.tgz | tar xz
  fi
  cd gcc
  mkdir -p build
  cd build
  ../src/configure --disable-multilib --prefix=${DIR}/gcc --enable-languages=c,c++,fortran 
  make -j ${NPROCESSES}
  make install
fi
