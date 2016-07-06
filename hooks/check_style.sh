#!/usr/bin/env bash

# Go to temp dir containing the files to be committed
cd $1

# Loop over all files and check their style
FAIL=0
for FILE in `find . -type f`; do
  # exclude trg package
  if [ `echo ${FILE} | cut -c 1-6` = "./trg/" ]; then
    continue
  fi
  checkstyle "$FILE" > /dev/null
  if [ $? -ne 0 ]; then
    echo "checkstyle failed for "`echo $FILE | cut -c 3-`
    FAIL=1
  fi
done

# Fail check if at least one fails
exit $FAIL

