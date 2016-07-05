#!/usr/bin/env bash

# To check the files to be commited we need a temporary dir as there might
# be differences between the file in the index and the file on disk
TMPDIR=`mktemp -d`
if [ $? -ne 0 ]; then
  echo "Problem creating temp dir, aborting commit."
  exit 2
fi

# Find out which files were modified
FILES_MODIFIED=`git diff --cached --name-only`
# Place a copy of the versions to be commited in the temp dir
git checkout-index --prefix=$TMPDIR/ -- $FILES_MODIFIED
# Check all the files in the temp dir and write which ones failed the check
FAIL=0
for FILE in $FILES_MODIFIED; do
  # Suppressing output since the path would be wrong anyways
  checkstyle "$TMPDIR/$FILE" > /dev/null
  if [ $? -ne 0 ]; then
    echo "checkstyle failed for $FILE"
    FAIL=1
  fi
done

# If at least one fails, abort commit
if [ $FAIL -ne 0 ]; then
  echo "Commit aborted, please run 'fixstyle' on the files listed above and 'git add' them to your commit again."
fi

# Clean up the temp dir
rm -r $TMPDIR
exit $FAIL

