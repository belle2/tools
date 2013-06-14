#!/bin/bash

if [ `uname` = Darwin ]; then
  # Mac OS
  MISSING=""
  which make > /dev/null 
  if [ $? != 0 ]; then
    MISSING="${MISSING}, XCode command line tools"
  fi
  for TOOL in cmake fink gfortran; do
    which ${TOOL} > /dev/null
    if [ $? != 0 ]; then
      MISSING="${MISSING}, ${TOOL}"
    fi
  done
  if [ "${MISSING}" != "" ]; then
    echo "Please install the following:" `echo ${MISSING} | cut -c 2-`
    exit 1
  fi
  PACKAGES="wget"
  OPTIONALS=""
  CHECK_CMD="dpkg -s"
  SU_CMD="sudo"
  INSTALL_CMD="fink install"

elif [ -f /etc/lsb-release ]; then
  # Ubuntu
  PACKAGES="subversion make gcc g++ gfortran binutils patch wget python-dev libxml2-dev dpkg-dev libx11-dev libxpm-dev libxft-dev libxext-dev libbz2-dev libncurses5-dev libreadline-dev lsb-release unzip"
  OPTIONALS="libglu1-mesa-dev libglew1.5-dev"
  CHECK_CMD="dpkg -s"
  SU_CMD="sudo"
  INSTALL_CMD="apt-get install"

elif [ -f /etc/debian_version ]; then
  # Debian
  PACKAGES="subversion make gcc g++ gfortran binutils patch wget python-dev libxml2-dev dpkg-dev libx11-dev libxpm-dev libxft-dev libxext-dev libbz2-dev libssl-dev libncurses5-dev libreadline-dev lsb-release"
  OPTIONALS="libglu1-mesa-dev libglew1.5-dev"
  CHECK_CMD="dpkg -s"
  SU_CMD="su -c"
  INSTALL_CMD="apt-get install"

elif [ -f /etc/SuSE-release ]; then
  # OpenSUSE
  PACKAGES="subversion make gcc gcc-c++ libgfortran45 binutils patch wget python-devel libxml2-devel xorg-x11-libX11-devel xorg-x11-libXpm-devel xorg-x11-libXext-devel libbz2-devel ncurses-devel readline-devel" 
  OPTIONALS="mesa-libGL-devel glew-devel"
  CHECK_CMD="rpm -q"
  SU_CMD="su -c"
  INSTALL_CMD="yum install"

else
  if [ ! -f /etc/redhat-release ]; then
    echo "Unknown linux distribution. Trying installation with yum..."
  fi
  # RH, SL, CentOS
  PACKAGES="subversion make gcc gcc-c++ gcc-gfortran binutils patch wget python-devel libxml2-devel libX11-devel libXpm-devel libXft-devel libXext-devel bzip2-devel openssl-devel ncurses-devel readline-devel"
  OPTIONALS="mesa-libGL-devel glew-devel"
  CHECK_CMD="rpm -q"
  SU_CMD="su -c"
  INSTALL_CMD="yum install"
fi
TEXT="already"


# check for missing packages
MISSING_PACKAGES=""
for PACKAGE in ${PACKAGES}; do
  ${CHECK_CMD} ${PACKAGE} &> /dev/null
  if [ "$?" != 0 ]; then
    MISSING_PACKAGES="${MISSING_PACKAGES} ${PACKAGE}"
  fi
done

# check for missing optional packages
MISSING_OPTIONALS=""
for PACKAGE in ${OPTIONALS}; do
  ${CHECK_CMD} ${PACKAGE} &> /dev/null
  if [ "$?" != 0 ]; then
    MISSING_OPTIONALS="${MISSING_OPTIONALS} ${PACKAGE}"
  fi
done


# ask the user to install the missing packages
if [ -n "${MISSING_PACKAGES}" ]; then
  TEXT="now"
  INSTALL_MISSING=${INSTALL_CMD}${MISSING_PACKAGES}
  if [ "${SU_CMD}" != "sudo" ]; then
    INSTALL_MISSING=\"${INSTALL_MISSING}\"
  fi
  echo "The following packages are missing:${MISSING_PACKAGES}

Please install them with the following command:

  ${SU_CMD} ${INSTALL_MISSING}

You will need root access to run this command.
"
  read -p "Would you like to execute it now (y/n)? " -n 1 REPLY 
  echo
  if [ "$REPLY" = "y" ]; then
    if [ "${SU_CMD}" != "sudo" ]; then
      ${SU_CMD} "${INSTALL_CMD}${MISSING_PACKAGES}"
    else
      ${SU_CMD} ${INSTALL_MISSING}
    fi
    if [ "$?" != 0 ]; then
      exit 1
    fi
  else
    exit 1
  fi
fi

# ask the user about the optional packages
if [ -n "${MISSING_OPTIONALS}" ]; then
  TEXT="now"
  INSTALL_MISSING=${INSTALL_CMD}${MISSING_OPTIONALS}
  if [ "${SU_CMD}" != "sudo" ]; then
    INSTALL_MISSING=\"${INSTALL_MISSING}\"
  fi
  echo "The following optional packages (required to build the event display) are not installed:${MISSING_OPTIONALS}

You can install them with the following command:

  ${SU_CMD} ${INSTALL_MISSING}

You will need root access to run this command.
"
  read -p "Would you like to execute it now (y/n)? " -n 1 REPLY 
  echo
  if [ "$REPLY" = "y" ]; then
    if [ "${SU_CMD}" != "sudo" ]; then
      ${SU_CMD} "${INSTALL_CMD}${MISSING_OPTIONALS}"
    else
      ${SU_CMD} ${INSTALL_MISSING}
    fi
    if [ "$?" != 0 ]; then
      exit 1
    fi
  else
    exit 1
  fi
fi


echo "
All software that is required to build the Belle II software is ${TEXT}
installed on your system.
"
