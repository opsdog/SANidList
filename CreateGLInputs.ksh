#!/bin/ksh
##
##  script to create SAN ranges and input files for SAN adds
##
##  will prompt for what it needs
##

SANMapDir=/Volumes/External300/DBProgs/FSRServers/Inputs-SANmap

##
##  get required info
##

echo -n "Server name:  "
read ServerName
echo -n "Disk tag:  "
read LunTag

echo -n "Disk group:  "
read DiskGroup
echo -n "Volume template:  "
read VolumeTemplate
echo -n "Starting DM number:  "
read DMStartNumber
echo -n "Starting Volume number:  "
read VolStartNumber

echo -n "Array Serial:  "
read ArrayDEC
echo -n "Starting LUN id:  "
read LunIDStart
echo -n "Ending LUN id:  "
read LunIDEnd

##
##  test values
##

##  ServerName=cupsd08a0100
##  DiskGroup=u1apx01_datadg_asm
##  VolumeTemplate=u1apx01_datadg_asm_vol
##  DMStartNumber=16
##  VolStartNumber=16
##  ArrayDEC=29738
##  LunIDStart=03:F3
##  LunIDEnd=03:F7
##  LunTag=UAT

ArrayHEX=`echo "obase=16; $ArrayDEC" | bc`
ArrayHEXF=`printf %05X $ArrayDEC`

echo
echo "$ServerName"
echo "$DiskGroup $VolumeTemplate $DMStartNumber $VolStartNumber"
echo "$ArrayDEC --> $ArrayHEX --> $ArrayHEXF $LunIDStart $LunIDEnd"
echo

##
##  create the servername+disk_group files with the LUN ids
##

./CreateRange $LunIDStart $LunIDEnd > ${ServerName}+${DiskGroup}

##
##  get the CTDs from the latest SAN2 csv
##

##  SANMapFile=`ls -l ${SANMapDir}/${ServerName}_SAN2_*.csv 2>/dev/null | tail -1 | awk '{ print $NF }'`
SANMapFile=`ls -l ${SANMapDir}/${ServerName}_SAN3_*.csv 2>/dev/null | tail -1 | awk '{ print $NF }'`

echo "SAN map:  $SANMapFile"

rm -f ${ServerName}+${DiskGroup}.CTD
touch ${ServerName}+${DiskGroup}.CTD

for LUNid in `cat ${ServerName}+${DiskGroup}`
do
  ## echo "$ArrayHEX $LUNid"
  cat $SANMapFile | awk -F\, ' $2 == arrayhex && $3 == lunid  { print $1 }' arrayhex=$ArrayHEXF lunid=$LUNid >> ${ServerName}+${DiskGroup}.CTD
done

##
##  create the servername+diskgroup.disks input file for the Create scripts
##  in the FSRServers/SANAdd directory
##
##  assume new volumes
##

echo "$DiskGroup $DMStartNumber $LunTag" > ${ServerName}+${DiskGroup}.disks
echo "$VolumeTemplate $VolStartNumber" >> ${ServerName}+${DiskGroup}.disks

##  read in the CTDs, strip the trailing "s2" and add the new flag

exec 4<${ServerName}+${DiskGroup}.CTD
while read -u 4 CTDS
do
  CTD=`echo $CTDS | sed s/s2$//`
  echo "$CTDS --> $CTD"
  echo "$CTD n" >> ${ServerName}+${DiskGroup}.disks
done
exec 4<&-
