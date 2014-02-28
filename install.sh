#!/bin/bash

# check whether the tools are already set up
if [ -n "${BELLE2_TOOLS}" ]; then
  echo "ERROR: Please run the install.sh script in a shell where the tools are NOT set up."
  exit 1
fi

# prepare directory for source code of tools
DIR=`python -c 'import os,sys;print os.path.realpath(sys.argv[1])' $(dirname $0)`
if [ ! -d ${DIR}/src ]; then
  mkdir ${DIR}/src
fi

# astyle
if [ ! -f ${DIR}/astyle ]; then
  cd ${DIR}/src
  wget -O - http://downloads.sourceforge.net/project/astyle/astyle/astyle%202.03/astyle_2.03_linux.tar.gz | tar xz
  if [ "$?" != "0" ]; then
    wget -O - --user=belle2 --password=Aith4tee https://belle2.cc.kek.jp/download/astyle_2.03_linux.tar.gz | tar xz
  fi
  cd astyle/build/gcc
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
if [ ! -f ${DIR}/gcc/bin/ld ]; then
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
  ../src/configure --disable-multilib --enable-shared --prefix=${DIR}/gcc
  make tooldir=${DIR}/gcc -j ${NPROCESSES}
  make tooldir=${DIR}/gcc install
fi

# gcc
if [ ! -f ${DIR}/gcc/bin/gcc ]; then
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

# setup gcc
if [ -z "${BELLE2_SYSTEM_COMPILER}" ]; then
  export PATH=${DIR}/gcc/bin:${PATH}
  if [ -n "${LD_LIBRARY_PATH}" ]; then
    export LD_LIBRARY_PATH=${DIR}/gcc/lib:${DIR}/gcc/lib64:${LD_LIBRARY_PATH}
  else
    export LD_LIBRARY_PATH=${DIR}/gcc/lib:${DIR}/gcc/lib64
  fi
fi

# python
if [ ! -f ${DIR}/python/bin/python ]; then
  cd ${DIR}/src
  if [ ! -d ${DIR}/src/python ]; then
    wget -O - --tries=3 --no-check-certificate --user=belle2 --password=Aith4tee https://belle2.cc.kek.jp/download/Python-2.7.6.tgz | tar xz
  fi
  cd python
  UCS=`python -c 'import sys;ucs = {};ucs[True] = "ucs4";ucs[False] = "ucs2";print ucs[sys.maxunicode > 65535]'`
  ./configure --enable-shared --enable-unicode=${UCS} --prefix=${DIR}/python
  make -j ${NPROCESSES}
  make install
fi
export LD_LIBRARY_PATH=${DIR}/python/lib:${LD_LIBRARY_PATH}
if [ -n "${PYTHONPATH}" ]; then
  export PYTHONPATH=${DIR}/python/lib/python2.7:${PYTHONPATH}
else
  export PYTHONPATH=${DIR}/python/lib/python2.7
fi

# virtualenv
if [ ! -f ${DIR}/python/bin/virtualenv ]; then
  cd ${DIR}/src
  if [ ! -d ${DIR}/src/virtualenv ]; then
    wget -O - --tries=3 --no-check-certificate --user=belle2 --password=Aith4tee https://belle2.cc.kek.jp/download/virtualenv-1.10.1.tar.gz | tar xz
  fi
  cd virtualenv
  ../../python/bin/python setup.py install --prefix=${DIR}/python
fi

# create virtualenv
if [ ! -f ${DIR}/virtualenv/bin/activate ]; then
  cd ${DIR}
  python/bin/virtualenv virtualenv
  python/bin/virtualenv --relocatable virtualenv
  sed -i "s;${DIR};\${BELLE2_TOOLS};g" virtualenv/bin/activate*
fi

# install some python packages
BELLE2_TOOLS=${DIR} .  ${DIR}/virtualenv/bin/activate
for PYPKG in numpy==1.8.0 ipython==1.1.0 pep8==1.4.6 pep8ify==0.0.11; do
  PYSTR=`echo ${PYPKG} | awk -F = '{print $1" ("$NF")"}'`
  PYEXISTS=`pip list | grep "${PYSTR}" |wc -l`
  if [ "${PYEXISTS}" == 0 ]; then
     pip install ${PYPKG}
  fi
done

# remove pep8.pyc
rm -f ${DIR}/pep8.pyc
