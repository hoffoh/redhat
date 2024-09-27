#!/bin/bash
# V4
# Added colours to error
# Created if statement for hostname not found, and re-direct to error
# Removed md5 from list
# get_cases function with error and alignment
######################Vars###################################

LINE="echo -------------------------------------------------------------------------------------------------------"
RED="\0033[1;31m""-------------------------------------------------------------------------------------------------------"

##################Functions##################################

function get_case (){
clear
$LINE
echo "-                                   List of cases downloaded                                          -"
GETCASES=`ls -ltr ~ | grep cases | cut -d "/" -f 3`
if [[ -z ${GETCASES} ]]
then
  echo -e "$RED"
  echo -e "NO CASES FOUND ON THE DIRECTORY""\0033[0m"
else
  $LINE
  for n in $(echo $GETCASES)
  do 
    echo "-    $n" 
  done
fi
$LINE && $LINE
read -p " Case Number:> " CASE
}

function get_data (){
clear
$LINE
echo "case number $CASE"
$LINE
ls -1d ~/$CASE/*-"sos"* | grep -v md5
$LINE 
echo "#    From list, select the case report XXX0-sos-report name from 1 to 999   #"
$LINE && $LINE
read -p "     First sos report number :> " SEQ0
$LINE && $LINE
read -p "      Last sos report number  :> " SEQ1
clear
FILES="$SEQ0 $SEQ1"
}

function grep_soft (){
echo [SOFTWARE INFO]
for i in $(seq -f '%03g' $FILES)
do 
  GETFOLDERNAME=`ls -1d ~/$CASE/$i* 2>/dev/null`
  GETNAME=`cat $GETFOLDERNAME/*/etc/hostname 2>/dev/null`
  if [[ -z ${GETNAME} ]]
  then
    echo -e "$RED"
    echo -e "Please check the content of $CASE/$i""0-sos-report- ... NO DATA FOUND ON THIS FOLDER""\0033[0m"
  else
    $LINE
    echo "-#@:> $GETNAME"
    cat $GETFOLDERNAME/*/etc/redhat-release 2>/dev/null
    grep -E "glusterfs-server|glusterfs-fuse" $GETFOLDERNAME/*/installed-rpms 2>/dev/null
  fi
done
$LINE
}

function grep_gluster (){
echo [GLUSTER]
$LINE
for o in $(seq -f '%03g' $FILES)
do 
  GETFOLDERNAME=`ls -1d ~/$CASE/$o* 2>/dev/null`
  VOLUMEINFO=`grep -E "Name|Type|Number| $" $GETFOLDERNAME/*/sos_commands/gluster/gluster_volume_info 2>/dev/null`
  GETBRICKSOFF=`grep " N " $GETFOLDERNAME/*/sos_commands/gluster/gluster_volume_status 2>/dev/null | grep -v "Daemon"`
  GETPOOLINFO=`cat  $GETFOLDERNAME/*/sos_commands/gluster/gluster_pool_list 2>/dev/null`

# Check info from gluster on each entrie, if matches get data
  if [[ -z ${VOLUMEINFO} ]]
  then
   : 
  else
    echo "- Gluster File: $GETFOLDERNAME"
    $LINE
    echo "${VOLUMEINFO[*]}"
#Checking bricks
    if [[ -z $GETBRICKSOFF ]]
    then
      $LINE
      echo "-                                 No Bricks Offline found                                             -"
    else
      echo -e $RED
      echo -e "-                                Detected OFFLINE Bricks                                              -"
      echo ""
      echo -e "${GETBRICKSOFF[*]}""\0033[0m"
    fi
    $LINE
    echo "Gluster Pool info"
    echo ""
    echo "${GETPOOLINFO[*]}"
    $LINE
    break 
  fi
done
}
##########################Main#####################################

get_case
get_data
grep_soft
grep_gluster
#Just to check how exits
#echo "END OF SCRIPT"
