#!/bin/bash

# This script is meant to run in a clean environment (docker container) where
# cvmfs is configured and available to test the basf2 tools.
# We install all the requirements and try to setup all the supported releases
# in all supported shells.

# check if we need to run only b2install-prepare
ONLY_B2INSTALL_PREPARE=no
for i in "$@"; do
  case $i in
    --only-b2install-prepare)
      ONLY_B2INSTALL_PREPARE=yes
      ;;
    esac
done

set -e

if [ "$ONLY_B2INSTALL_PREPARE" = "no" ]; then
  export BELLE2_TOOLS=$(cd -P $(dirname  $0)/.. && pwd -P)
  # we're testing development version of the tools, so we shouldn't check if they're up to date.
  export BELLE2_NO_TOOLS_CHECK=yes
  # make sure we find releases on cvmfs
  export VO_BELLE2_SW_DIR=/cvmfs/belle.cern.ch/$(${BELLE2_TOOLS}/b2install-print-os | tr -d " ")
  echo "Look for releases and externals in ${VO_BELLE2_SW_DIR}"
fi

# now we actually need zsh and tcsh for the tests
for INSTALLER in dnf yum apt-get; do
  if [ -x "$(command -v ${INSTALLER})" ]; then
    # of course ubuntu needs to check for updates manually
    if [ "${INSTALLER}" == "apt-get" ]; then
      # make sure debian doesn't ask silly questions
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
    fi
    if [ "$ONLY_B2INSTALL_PREPARE" = "no" ]; then
      ${INSTALLER} install -y tcsh zsh
    fi
    break
  fi
done

# install all the dependencies
${BELLE2_TOOLS}/b2install-prepare --non-interactive

if [ "$ONLY_B2INSTALL_PREPARE" = "yes" ]; then
  exit 0
fi

# and execute all test scripts we might have
shopt -s nullglob extglob
for TEST in ${BELLE2_TOOLS}/tests/+([0-9])-*; do
  # execute tests ending with .sh with both bash and zsh shells
  if [[ ${TEST} == *.sh ]]; then
    echo "Executing '${TEST}' with bash"
    bash ${TEST};
    echo "...done"
    echo "Executing '${TEST}' with zsh"
    zsh ${TEST};
    echo "...done"
  fi
  # and execute tests ending with .csh with tcsh shell
  if [[ ${TEST} == *.csh ]]; then
    echo "Executing '${TEST}' with tcsh"
    tcsh ${TEST};
    echo "...done"
  fi
done
exit 0