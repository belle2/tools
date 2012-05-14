#!/bin/bash

# check for help option
if [ "$1" = "--help" -o "$1" = "-h" -o "$1" = "-?" ]; then
  echo
  echo "Usage: `basename $0` [version]"
  echo
  echo "- This command installs the given version of the externals in the"
  echo "  directory given by the environment variable BELLE2_EXTERNALS_TOPDIR."
  echo "- If no version is given it lists the available externals versions."
  echo
  exit 0
fi

# check number of arguments
if [ $# -gt 1 ]; then
  echo "Usage: `basename $0` [version]" 1>&2
  exit 1
fi

# check for software tools setup
if [ -z "${BELLE2_REPOSITORY}" -o -z "${BELLE2_EXTERNALS_TOPDIR}" ]; then
  echo "Belle II software environment is not set up." 1>&2
  echo "-> Source \"setup_belle2.sh\" (for bash) or \"setup_belle2.csh\" (for csh)." 1>&2
  exit 1
fi

# list available versions if no argument is given
if [ $# -eq 0 ]; then
  svn list ${BELLE2_REPOSITORY}/tags/externals | sed "s;/$;;g"
  REVISION=`svn list --verbose --depth=empty ${BELLE2_REPOSITORY}/trunk/externals | awk '{print $1}'`
  echo "development (revision ${REVISION})"
  exit 0
fi


# check for geant4 and root setup
if [ -n "${G4SYSTEM}" ]; then
  echo "Geant4 setup detected." 1>&2
  echo "Please build the externals in a shell where geant4 is not set up" 1>&2
  exit 1
fi
if [ -n "${ROOTSYS}" ]; then
  echo "Root setup detected." 1>&2
  echo "Please build the externals in a shell where root is not set up" 1>&2
  exit 1
fi

# check whether the given version is already installed
VERSION=$1
DIR=${BELLE2_EXTERNALS_TOPDIR}/${VERSION}
if [ -d ${DIR} ]; then
  echo "Error: The externals version ${VERSION} is already installed at ${BELLE2_EXTERNALS_TOPDIR}." 1>&2
  exit 1
fi

# check whether the given version is available
if [ "${VERSION}" != "development" ]; then
  svn list ${BELLE2_REPOSITORY}/tags/externals/${VERSION} > /dev/null
  if [ "$?" != "0" ]; then
    echo "Error: The externals version ${VERSION} does not exist." 1>&2
    exit 1
  fi
fi

# check whether the externals top directory exists
if [ ! -d ${BELLE2_EXTERNALS_TOPDIR} ]; then
  echo "The externals top directory ${BELLE2_EXTERNALS_TOPDIR} does not exist."
  read -p "Would you like to create it (y/n)? " -n 1 REPLY 
  echo
  if [ "$REPLY" = "y" ]; then
    mkdir -p ${BELLE2_EXTERNALS_TOPDIR}
    if [ "$?" != 0 ]; then
      echo "Error: The creation of the directory ${BELLE2_EXTERNALS_TOPDIR} failed." 1>&2
      exit 1
    fi
  else
    exit 1
  fi
fi

# accept the geant4_vmc svn server certificate
echo p | svn list https://root.cern.ch/svn/geant4_vmc/ &> /dev/null 

# check out the selected version
cd ${BELLE2_EXTERNALS_TOPDIR}
if [ "${VERSION}" != "development" ]; then
  svn co --non-interactive --trust-server-cert ${BELLE2_REPOSITORY}/tags/externals/${VERSION}
else
  svn co --non-interactive --trust-server-cert ${BELLE2_REPOSITORY}/trunk/externals development
fi

if [ "$?" != 0 ]; then
  echo "\nError: The svn checkout of the externals failed." 1>&2
  exit 2
fi

# build the externals
cd ${VERSION}
make 2>&1 | tee make.log

if [ "$?" != 0 ]; then
  echo "\nError: The compilation of the externals failed." 1>&2
  echo "Please check the compilation log, try to fix the problem, and rerun make in ${BELLE2_EXTERNALS_TOPDIR}/${VERSION}." 1>&2
  exit 3
fi
