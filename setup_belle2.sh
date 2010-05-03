# add tools directory to path
export BELLE2_TOOLS=$(readlink -f "`dirname $BASH_SOURCE`")
if [ -n "${PATH}" ]; then
  export PATH=${BELLE2_TOOLS}:${PATH}
else
  export PATH=${BELLE2_TOOLS}
fi

# set top directory of Belle II software installation
if [ -z "${VO_BELLE2_SW_DIR}" ]; then
  export VO_BELLE2_SW_DIR=$(readlink -f "${BELLE2_TOOLS}/..")
fi

# set location of Belle II code repository
export BELLE2_REPOSITORY=https://b2comp.kek.jp

# define functions for release setup
function setuprel
{
  . ${BELLE2_TOOLS}/setuprel.sh
}