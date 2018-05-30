#!/bin/bash
set -o pipefail

echo "HINT: get_release.sh is deprecated, instead use: b2install-release"

# check for help option
if [ "$1" = "--help" -o "$1" = "-h" -o "$1" = "-?" ]; then
  echo
  echo "Usage: `basename $0` [version [system]]"
  echo
  echo "- This command installs the given release or build version of basf2"
  echo "  in the directory $VO_BELLE2_SW_DIR/releases."
  echo "- If the operating system is specified it tries to install the"
  echo "  corresponding precompiled binary version."
  echo "- If no version is given it lists the available versions."
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
if [ -z "${BELLE2_SOFTWARE_REPOSITORY}" -o -z "${VO_BELLE2_SW_DIR}" ]; then
  echo "Belle II software environment is not set up." 1>&2
  echo "-> source setup_belle2" 1>&2
  exit 1
fi

# list available versions if no argument is given
if [ $# -eq 0 ]; then
  git ls-remote ${BELLE2_SOFTWARE_REPOSITORY} | grep "tags/" | grep "release-\|build-" | grep -v "\^{}$" | awk -F / '{print $NF}'
  exit 0
fi


# check whether the given version is already installed
VERSION=$1
DIR=${VO_BELLE2_SW_DIR}/releases/${VERSION}
if [ -d ${DIR} ]; then
  echo "Error: The basf2 version ${VERSION} is already installed at ${VO_BELLE2_SW_DIR}/releases." 1>&2
  exit 1
fi

# check whether the releases top directory exists and cd to it
if [ ! -d ${VO_BELLE2_SW_DIR}/releases ]; then
  echo "The basf2 releases top directory ${VO_BELLE2_SW_DIR}/releases does not exist."
  read -p "Would you like to create it (y/n)? " -n 1 REPLY 
  echo
  if [ "$REPLY" = "y" ]; then
    mkdir -p ${VO_BELLE2_SW_DIR}/releases
    if [ "$?" != 0 ]; then
      echo "Error: The creation of the directory ${VO_BELLE2_SW_DIR}/releases failed." 1>&2
      exit 1
    fi
  else
    exit 1
  fi
fi
cd ${VO_BELLE2_SW_DIR}/releases

# check whether we can write to the releases directory
if [ ! -w ${VO_BELLE2_SW_DIR}/releases ]; then
  echo "Error: No write permissions to the directory ${VO_BELLE2_SW_DIR}/releases." 1>&2
  exit 1
fi

# try the binary version if the operating system is given
if [ $# -gt 1 ]; then
  wget -O - --tries=3 ${BELLE2_DOWNLOAD}/releases/${VERSION}_$2.tgz | tar xz
  if [ "$?" = "0" ]; then
    exit 0
  fi
fi

# try the source version
wget -O - --tries=3 ${BELLE2_DOWNLOAD}/releases/${VERSION}_src.tgz | tar xz
if [ "$?" != "0" ]; then
  # check whether the given version is available in the git repository
  VERSION_EXISTS=`git ls-remote ${BELLE2_SOFTWARE_REPOSITORY} ${VERSION} | wc -l`
  if [ "${VERSION_EXISTS}" = "0" ]; then
    echo "Error: The basf2 version ${VERSION} does not exist." 1>&2
    exit 1
  fi
  git archive --format=tar.gz --prefix=${VERSION}/ --remote=${BELLE2_SOFTWARE_REPOSITORY} ${VERSION} | tar xzv
  if [ "$?" != 0 ]; then
    echo "Error: The download of ${VERSION} from the git repository failed." 1>&2
    exit 2
  fi
fi

# build basf2
cd ${VERSION}
echo head > .release
ln -s site_scons/SConstruct .
. ${BELLE2_TOOLS}/setup_belle2.sh
setuprel
scons

if [ "$?" != 0 ]; then
  echo "Error: The compilation of basf2 failed." 1>&2
  exit 3
fi
