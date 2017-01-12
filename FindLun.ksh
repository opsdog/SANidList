#!/bin/ksh
##
##  script to read the sequences and generate a list of server and CTD
##
##  usefull for making sure the SAN is visible on the servers expected
##

##  make sure we are working with only the current SAN map files

( cd /Volumes/External300/DBProgs/FSRServers/Inputs-SANmap ; ./LeaveOne.ksh >/dev/null )

##  clean up prior runs

rm -f *CTD

##  sanity check

LUNCountWC=`wc -l [a-z]* | tail -1 | awk '{ print $1 }'`
LUNCountSort=`cat [a-z]* | sort -u | wc -l | awk '{ print $1 }'`

if [ $LUNCountWC -ne $LUNCountSort ]
then
  echo "LUN counts do not match - bailing..."
#  exit
fi

##
##  let's roll
##

for File in [a-z]*
do
  ServerName=`echo $File | awk -F\+ '{ print $1 }'`
  DiskGroup=`echo $File | awk -F\+ '{ print $2 }'`
  echo "$File - $ServerName $DiskGroup"
  FileServCTD="${File}-servCTD"
  FileCTD="${File}.CTD"
  rm -f $FileServCTD $FileCTD
  touch $FileServCTD $FileCTD
  for LUN in `cat $File`
  do
    ## echo "    Checking for $LUN"
    ## grep -i "$LUN" /Volumes/External300/DBProgs/FSRServers/Inputs-SANmap/*.csv | tr \- \  | tr \: \  | tr \, \  | awk '{ print $2" "$3 }' | sed s/SANmap// >> $FileServCTD
    grep -i "$LUN" /Volumes/External300/DBProgs/FSRServers/Inputs-SANmap/${ServerName}*.csv | tr \- \  | tr \: \  | tr \, \  | awk '{ print $2" "$3 }' | sed s/SANmap// >> $FileServCTD
  done
  cat $FileServCTD | awk '{ print $2 }' > $FileCTD
done
