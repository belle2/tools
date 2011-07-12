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
  exit 0
fi


# check whether the given version is already installed
VERSION=$1
DIR=${BELLE2_EXTERNALS_TOPDIR}/${VERSION}
if [ -d ${DIR} ]; then
  echo "Error: The externals version ${VERSION} is already installed at ${BELLE2_EXTERNALS_TOPDIR}." 1>&2
  exit 1
fi

# check whether the given version is available
svn list ${BELLE2_REPOSITORY}/tags/externals/${VERSION} &> /dev/null
if [ "$?" != "0" ]; then
  echo "Error: The externals version ${VERSION} does not exist." 1>&2
  exit 1
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

# check out the selected version
cd ${BELLE2_EXTERNALS_TOPDIR}
svn co ${BELLE2_REPOSITORY}/tags/externals/${VERSION}

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
