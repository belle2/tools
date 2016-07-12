#!/bin/bash
set -o pipefail

# check for help option
if [ "$1" = "--help" -o "$1" = "-h" -o "$1" = "-?" ]; then
  echo
  echo "Usage: `basename $0` [version [system]]"
  echo
  echo "- This command installs the given version of the externals in the"
  echo "  directory given by the environment variable BELLE2_EXTERNALS_TOPDIR."
  echo "- If the operating system is specified it tries to install the"
  echo "  corresponding precompiled binary version."
  echo "- If no version is given it lists the available externals versions."
  echo
  exit 0
fi

# make sure tar uses stdin
unset TAPE

# check number of arguments
if [ $# -gt 2 ]; then
  echo "Usage: `basename $0` [version [system]]" 1>&2
  exit 1
fi

# check for software tools setup
if [ -z "${BELLE2_EXTERNALS_REPOSITORY}" -o -z "${BELLE2_EXTERNALS_TOPDIR}" ]; then
  echo "Belle II software environment is not set up." 1>&2
  echo "-> source setup_belle2" 1>&2
  exit 1
fi

# list available versions if no argument is given
if [ $# -eq 0 ]; then
  git ls-remote ${BELLE2_EXTERNALS_REPOSITORY} | grep "tags/" | grep -v "\^{}$" | awk -F / '{print $NF}'
  COMMIT=`git ls-remote ${BELLE2_EXTERNALS_REPOSITORY} master | awk '{print $1}'`
  echo "development (commit ${COMMIT})"
  exit 0
fi


# check whether the given version is already installed
VERSION=$1
DIR=${BELLE2_EXTERNALS_TOPDIR}/${VERSION}
if [ -d ${DIR} ]; then
  echo "Error: The externals version ${VERSION} is already installed at ${BELLE2_EXTERNALS_TOPDIR}." 1>&2
  exit 1
fi

# check whether the externals top directory exists and cd to it
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
cd ${BELLE2_EXTERNALS_TOPDIR}

# check whether we can write to the externals directory
if [ ! -w ${BELLE2_EXTERNALS_TOPDIR} ]; then
  echo "Error: No write permissions to the directory ${BELLE2_EXTERNALS_TOPDIR}." 1>&2
  exit 1
fi

function CheckBuildEnvironment ()
{
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

  # accept the geant4_vmc svn server certificate
  echo p | svn list https://root.cern.ch/svn/geant4_vmc/ &> /dev/null 
}

# check out the selected version
if [ "${VERSION}" = "development" ]; then
  CheckBuildEnvironment
  git clone ${BELLE2_EXTERNALS_REPOSITORY} development
else

  # try the binary version if the operating system is given
  if [ $# -gt 1 ]; then
    wget -O - --tries=3 ${BELLE2_DOWNLOAD}/externals/externals_${VERSION}_$2.tgz | tar xz
    RESULT=$?
    if [ "${RESULT}" = "0" ]; then
      exit 0
    fi
  fi

  # next try the externals source tarball and then the checkout from the svn repository
  CheckBuildEnvironment
  wget -O - --tries=3 ${BELLE2_DOWNLOAD}/externals/externals_${VERSION}_src.tgz | tar xz
  RESULT=$?
  if [ "${RESULT}" -ne "0" ]; then
    # check whether the given version is available
    git ls-remote ${BELLE2_EXTERNALS_REPOSITORY} ${VERSION} > /dev/null
    if [ "$?" != "0" ]; then
      echo "Error: The externals version ${VERSION} does not exist." 1>&2
      exit 1
    fi
    git clone --branch release/${VERSION} ${BELLE2_EXTERNALS_REPOSITORY} ${VERSION}
  fi
fi

if [ "$?" != 0 ]; then
  echo "\nError: The git checkout of the externals failed." 1>&2
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
