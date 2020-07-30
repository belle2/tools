#!/bin/bash

# This script is meant to run in a clean environment (docker container) where
# cvmfs is configured and available to test the belle2 software tools We install
# all the requirements and try to setup all the supported releases in all
# supported shells

set -e
export BELLE2_TOOLS=$(cd -P $(dirname  $0)/.. && pwd -P)
# we're testing development version of the tools ... so we shouldn't check if they're up to date.
export BELLE2_NO_TOOLS_CHECK=yes
# make sure we find releases on cvmfs
export VO_BELLE2_SW_DIR=/cvmfs/belle.cern.ch/$(${BELLE2_TOOLS}/b2install-print-os | tr -d " ")
echo "Look for releases and externals in ${VO_BELLE2_SW_DIR}"

# now we actually need tcsh for the tests ... *sigh*
for INSTALLER in dnf yum apt-get; do
  if [ -x "$(command -v ${INSTALLER})" ]; then
    # of course ubuntu needs to check for updates manually.
    if [ "${INSTALLER}" == "apt-get" ]; then
      # make sure debian doesn't ask silly questions
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
    fi
    ${INSTALLER} install -y tcsh
    break
  fi
done

# install all the dependencies
${BELLE2_TOOLS}/b2install-prepare --non-interactive

# and execute all test scripts we might have
shopt -s nullglob extglob
for f in ${BELLE2_TOOLS}/tests/+([0-9])-*; do
  echo "Executing '$f'"
  $f;
  echo "...done"
done
exit 0
