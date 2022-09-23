#!/bin/bash
# This script generates a provided-scripts.rst file from the --documentation option in all Belle II bash scripts.
# The argument specifies the relative directory provided-scripts.rst should be written to.

target=$1/provided-scripts.rst

exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    echo "$LIST" | tr "$DELIMITER" '\n' | grep -F -q -x "$VALUE"
}


cat << EOF > "$target"
Provided Scripts
----------------

The Belle II Software Tools provide a number of scripts common to all software
versions to setup and use the Belle II Software.

For users
+++++++++
EOF

userscripts="b2analysis-create b2analysis-get b2install-release b2install-externals b2install-data"

for file in $userscripts ; do

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
    echo "${BELLE2_TOOLS}/$file doesn't exist."
    exit 1
  fi
done

cat << EOF >> "$target"

For developers
++++++++++++++

EOF

# Here we'll just loop over everything else that looks like a bash script.
for filepath in "${BELLE2_TOOLS}"/* ; do
  
  # Make sure we haven't already processed this shell script	
  file="$(basename "$filepath")"
  if ! exists_in_list "$userscripts" " " "$file" ; then
    # Check it's a file
    if [ -f "${BELLE2_TOOLS}/$file" ]; then
      # Check it's a shell script and not something else
      if [ "$(head -n 1 "${BELLE2_TOOLS}/$file")" = "#!/bin/bash" ]; then
          "${BELLE2_TOOLS}/$file" --documentation >> "$target"
      fi
    fi
  fi
done
