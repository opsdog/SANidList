#!/bin/ksh
##
##  script to read the sequences and generate a list of server and CTD
##
##  usefull for making sure the SAN is visible on the servers expected
##

##  make sure we are working with only the current SAN map files

SANMapDir=/Volumes/External300/DBProgs/FSRServers/Inputs-SANmap

## ( cd /Volumes/External300/DBProgs/FSRServers/Inputs-SANmap ; ./LeaveOne.ksh >/dev/null )

if [ "$1" = "-r" ]
then
  ( cd /Volumes/External300/DBProgs/FSRServers/ ; ./RefreshInputs.ksh >/dev/null )
fi

##  clean up prior runs

rm -f *CTD* *.SIZE zz-MissingLUNs.txt

##
##  let's roll
##

for File in `ls -l *.ArrayLUN 2>/dev/null | awk '{ print $NF }'`
do
  echo
  ServerName=`echo $File | awk -F\+ '{ print $1 }'`
  DiskGroup=`echo $File | awk -F\+ '{ print $2 }' | awk -F\. '{ print $1 }'`
  echo "$File - $ServerName $DiskGroup"
  FileBase=`echo $File | awk -F\. '{ print $1 }'`
  FileServCTD="${FileBase}-servCTD"
  FileCTDS2="${FileBase}.CTDS2"
  FileCTDS0="${FileBase}.CTDS0"
  FileCTD="${FileBase}.CTD"
  FileSize="${FileBase}.SIZE"
  rm -f $FileServCTD $FileCTD $FileCTDS2 $FileCTDS0 $FileSize
  ## touch $FileServCTD $FileCTD
  touch $FileCTD $FileCTDS2 $FileCTDS0 $FileSize

  ##  get the current SAN map file

  SANMap=`ls -l ${SANMapDir}/${ServerName}_SAN4_* 2>/dev/null | tail -1 | awk '{ print $NF }'`
  ##  echo "SANMap is $SANMap"
  gunzip -f $SANMap 2>/dev/null
  SANMap=`ls -l ${SANMapDir}/${ServerName}_SAN4_* 2>/dev/null | tail -1 | awk '{ print $NF }'`
  ##  echo "  SANMap is $SANMap"

  ##  read each array/LUN pair and find the CTD

  exec 4<$File
  while read -u 4 ArrayNumDEC LUNid
  do
    ArrayNumHEX=`printf %05X $ArrayNumDEC`
    ##  echo "  $ArrayNumDEC --> $ArrayNumHEX $LUNid"

    Res=`echo $LUNid | egrep \:`
    if [ -z "$Res" ]
    then
      FirstPair=`echo $LUNid | cut -c1-2`
      SecondPair=`echo $LUNid | cut -c3-4`
      LUNid=`echo "${FirstPair}:${SecondPair}"`
      ##  echo "  CONVERTED LUNid to $LUNid"
    fi


    VeritasP=`cat $SANMap | awk -F\, ' $3 == arrayhex && $4 == lunid { print $2 }' arrayhex=$ArrayNumHEX lunid=$LUNid`

    ##  echo "  VeritasP -->${VeritasP}<--"

    if [ -z "$VeritasP" ]
    then
      ##  echo "  non-veritas looking for $ArrayNumHEX $LUNid"
      CTDS2=`cat $SANMap | awk -F\, ' $3 == arrayhex && $4 == lunid { print $1 }' arrayhex=$ArrayNumHEX lunid=$LUNid`
      LUNsize=`cat $SANMap | awk -F\, ' $3 == arrayhex && $4 == lunid { print $5 }' arrayhex=$ArrayNumHEX lunid=$LUNid`
    else
      ##  echo "  veritas looking for $ArrayNumHEX $LUNid"
      cat $SANMap | awk -F\, ' $3 == arrayhex && $4 == lunid { print $2" "$5 }' arrayhex=$ArrayNumHEX lunid=$LUNid | sort -u | read CTDS2 LUNsize
    fi

    ##  echo "  CTDS2 --> $CTDS2"

    if [ ! -z "$CTDS2" ]
    then
      echo "$CTDS2"                 >> $FileCTDS2
      echo "$CTDS2" | sed s/s2$/s0/ >> $FileCTDS0
      echo "$CTDS2" | sed s/s2$//   >> $FileCTD
      echo "$CTDS2 $LUNsize"        >> $FileSize
    else
	echo "  MISSING LUN:  $ServerName $ArrayNumHEX (${ArrayNumDEC}) $LUNid"
	echo "  MISSING LUN:  $ServerName $ArrayNumHEX (${ArrayNumDEC}) $LUNid" >> zz-MissingLUNs.txt
    fi

  done
  exec 4<&-

done

##
##  sort the SIZE files by size, duh :-)
##

rm -f dougee69

for SizeFile in *.SIZE
do
  cat $SizeFile | sort -nk2 > dougee69
  mv dougee69 $SizeFile
done  ##  for each SIZE file

echo
