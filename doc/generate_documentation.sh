#!/bin/bash


cat << EOF > $1 
Provided Scripts
----------------

The Belle II Software Tools provide a number of scripts common to all software
versions to setup and use the Belle II Software.

For users
+++++++++
EOF

for file in b2analysis-create b2analysis-get b2install-release b2install-externals b2install-data ; do

  # Check it's a file
  if [ -f $2/"$file" ]; then
    # Check it's a shell script and not something else
    if [ "$(head -n 1 $2/$file)" = "#!/bin/bash" ]; then
        $2/$file --documentation >> $1 
    else
        echo "$2/$file is not a bash script"
        exit 1
    fi
  else
    echo "$2/$file is not a bash script"
    exit 1
  fi
done

cat << EOF >> $1 

For developers
++++++++++++++

EOF

for file in b2code-create b2code-style-check b2code-style-fix b2code-clean b2code-package-list b2code-package-add b2code-package-tag b2install-prepare ; do

  # Check it's a file
  if [ -f $2/"$file" ]; then
    # Check it's a shell script and not something else
    if [ "$(head -n 1 $2/$file)" = "#!/bin/bash" ]; then
        $2/$file --documentation >> $1 
    else
        echo "$2/$file is not a bash script"
        exit 1
    fi
  else
    echo "$2/$file is not a bash script"
    exit 1
  fi
done
