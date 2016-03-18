set BELLE2_TMP=`mktemp /tmp/belle2_tmp.XXXX`
$* >> $BELLE2_TMP
if ( $? != 0 ) then
  rm -f $BELLE2_TMP
  exit 1
endif

source $BELLE2_TMP
rm -f $BELLE2_TMP
rehash
