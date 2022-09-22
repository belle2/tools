#!/bin/bash
# This script generates a provided-scripts.rst file from the --documentation option in all Belle II bash scripts.
# The argument specifies the relative directory provided-scripts.rst should be written to.

target=$1/provided-scripts.rst

cat << EOF > "$target"
Provided Scripts
----------------

The Belle II Software Tools provide a number of scripts common to all software
versions to setup and use the Belle II Software.

For users
+++++++++
EOF

for file in b2analysis-create b2analysis-get b2install-release b2install-externals b2install-data ; do

  # Check it's a file
  if [ -f "${BELLE2_TOOLS}/$file" ]; then
    # Check it's a shell script and not something else
    if [ "$(head -n 1 "${BELLE2_TOOLS}/$file")" = "#!/bin/bash" ]; then
        "${BELLE2_TOOLS}/$file" --documentation >> "$target"
    else
        echo "${BELLE2_TOOLS}/$file is not a bash script"
        exit 1
    fi
  else
    echo "${BELLE2_TOOLS}/$file is not a bash script"
    exit 1
  fi
done

cat << EOF > "$target"

For developers
++++++++++++++

EOF

for file in b2code-create b2code-style-check b2code-style-fix b2code-clean b2code-package-list b2code-package-add b2code-package-tag b2install-prepare ; do

  # Check it's a file
  if [ -f "${BELLE2_TOOLS}/$file" ]; then
    # Check it's a shell script and not something else
    if [ "$(head -n 1 "${BELLE2_TOOLS}/$file")" = "#!/bin/bash" ]; then
        "${BELLE2_TOOLS}/$file" --documentation >> "$target"
    else
        echo "${BELLE2_TOOLS}/$file is not a bash script"
        exit 1
    fi
  else
    echo "${BELLE2_TOOLS}/$file is not a bash script"
    exit 1
  fi
done
