#!/bin/bash

if [ -f /etc/lsb-release ]; then
  # Ubuntu
  sudo apt-get install subversion make gcc g++ gfortran binutils python-dev libxml2-dev libx11-dev libxpm-dev libxft-dev libxext-dev libbz2-dev

elif [ -f /etc/debian_version ]; then
  # Debian
  su -c "apt-get install subversion make gcc g++ gfortran binutils python-dev libxml2-dev libx11-dev libxpm-dev libxft-dev libxext-dev libbz2-dev openssl-dev"

else
  if [ ! -f /etc/redhat-release ]; then
    echo "Unknown linux distribution. Trying installation with yum..."
  fi
  # RH, SL, CentOS
  su -c "yum install subversion make gcc gcc-c++ gcc-gfortran binutils python-devel libxml2-devel libX11-devel libXpm-devel libXft-devel libXext-devel openssl-devel"
fi

SVN_MAJOR_VERSION=`svn --version | head -1 | awk '{print $3}' | awk -F . '{print $1}'`
SVN_MINOR_VERSION=`svn --version | head -1 | awk '{print $3}' | awk -F . '{print $2}'`
if [ ${SVN_MAJOR_VERSION} -lt 2 ]; then
  if [ ${SVN_MINOR_VERSION} -lt 5 ]; then
    echo "**********************************************************"
    echo "* The installed svn version is too old.                  *"
    echo "* Downloading and compiling a new svn version...         *"
    echo "**********************************************************"
    wget http://subversion.tigris.org/downloads/subversion-1.6.13.tar.gz
    wget http://subversion.tigris.org/downloads/subversion-deps-1.6.13.tar.gz
    tar xzf subversion-1.6.13.tar.gz
    tar xzf subversion-deps-1.6.13.tar.gz
    cd subversion-1.6.13
    ./configure --prefix=${HOME}/subversion --with-ssl
    make
    make install
    rm -rf subversion-1.6.13.tar.gz subversion-deps-1.6.13.tar.gz subversion-1.6.13
  fi
fi
