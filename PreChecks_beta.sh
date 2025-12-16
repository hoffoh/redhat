#!/bin/bash
# Script to get report from pre-checks after upgrade from Ceph and ODF
# Manual intervention is required (case num and ODF MG Path) this only summarizes some info not checking all the data
# You can force to run on a path by entering the path as argument 
# Version 2
######################Vars###################################
clear
SPACE="echo " 
LINE="echo -------------------------------------------------------------------------------------------------------"
TITLES=("HEALTH" "DEVICES" "TREE" "OSD" "VERSION" "PVC" "CSV" "DEPLOYMENTS" "EVENTS" "PV" "OSD" "DETAIL" "HISTORY" "JOBS" "SKEW" "BLUESTORE" "STORAGECLUSTER" "PODS NOT RUNNING" "CEPH HISTORY" "NOOBAA" "DB PVC" "OBCs")
MANUALPATH=$1
CEPH_CMD=("ceph_health_detail" "ceph_status" "ceph_df_detail" "ceph_device_ls" "ceph_osd_df_tree" "ceph_versions" "ceph_time-sync-status" "ceph_healthcheck_history_ls")
OSD_HISTORY="cluster-scoped-resources/config.openshift.io/clusterversions/version.yaml"
##################Functions##################################

function main_menu (){
  get_case
  FILE="$CASENUM"_Pre.out && get_data 
  $LINE && $SPACE && echo "File: $FILE" && $SPACE && $LINE
}

function get_case (){
  clear
  $LINE
  echo "-                                   List of cases downloaded                                          -"
  GETCASES=`ls -ltr ~ | grep cases | cut -d "/" -f 3`
  if [[ -z ${GETCASES} ]]
  then
    echo -e "$LINE"
    echo -e "NO CASES FOUND ON THE DIRECTORY""\0033[0m"
  else
    $LINE
    for n in $(echo $GETCASES)
    do  
      echo -n "-    $n ->    " && date -d "$(stat -c %w ~/$n)" +"%d/%m/%Y"
    done
  fi
  $LINE && $LINE
  read -p " Case Number:> " CASENUM
}

function print_space(){
  echo '' >> $FILE
}

function print_title(){
  echo '' >> $FILE ; echo "--- ${TITLES[$X]} ---" >> $FILE ; echo '' >> $FILE
}

function print_ceph(){
  cat $CEPH_FINAL_PATH/${CEPH_CMD[$Y]} >> $FILE
}

function get_data (){
  $LINE && $SPACE && echo "Looking for ODF must-gathers on case: $CASENUM" && $SPACE && $LINE
  MGSUBPATH=$(find  ~/$CASENUM/ -maxdepth 3 -type d | grep -E "odf4-odf-must-gather|ocs-must-gather" | grep -Ev "ceph$|resources$|namespaces$|noobaa$|\.zip$" | sort )

  if [[ -n "$MANUALPATH" ]]
    then
      MGSUBPATH="/cases/$CASENUM/$MANUALPATH"
      FINAL_PATH="/cases/$CASENUM/$MANUALPATH"
      CEPH_FINAL_PATH="$FINAL_PATH/ceph/must_gather_commands"
      get_ceph
  #    $LINE &&  $SPACE && echo "Ceph path: $CEPH_FINAL_PATH" &&  echo "ODF path: $MGSUBPATH" && $SPACE
  #    echo "File: $FILE" && $SPACE
      exit 0
  fi

  if [[ -z $MGSUBPATH ]]
    then
      echo "Cannot find any ODF Must gather on:  ~/$CASENUM"
      $LINE && $SPACE && exit 66
    else
      echo "#    Select the ODF must-gather from list above   #"
      $LINE 
      SEQ=0
      for i in $MGSUBPATH
      do  
        SEQ=$((SEQ+1))
        $SPACE
        echo "  $SEQ: $i" 
        echo -n "    ^^^^ " && date -d "$(stat -c %w $i)" +"%d/%m/%Y"
        $SPACE 
      done 
      $LINE
      read -p "  Insert absolute path from above for the report :> " FINAL_PATH
      CEPH_FINAL_PATH=$FINAL_PATH/ceph/must_gather_commands
      $LINE
  fi
  get_ceph
}

function get_ceph (){
  echo "CASE: $CASENUM " > $FILE ; $LINE >> $FILE
  omc use $FINAL_PATH >> $FILE ; print_space ; omc project openshift-storage
  echo "[CEPH]" >> $FILE ; print_space
  X=11;print_title
  Y=0;print_ceph
  X=0;print_title
  Y=1;print_ceph
  X=18;print_title
  Y=7;print_ceph; echo >> $FILE
  Y=2;print_ceph
  X=2;print_title
  Y=4;print_ceph
  X=14;print_title
  Y=6;print_ceph
  X=15;print_title
  cat $CEPH_FINAL_PATH/ceph_report | jq -c '.osd_metadata[] | { OSD: .id, bluestore: .bluestore_min_alloc_size  }' >> $FILE
  X=1;print_title
  Y=3;print_ceph
  X=3;print_title
  egrep ^osd. $CEPH_FINAL_PATH/ceph_osd_dump | awk '{print $1 "    " $17}' >> $FILE
  X=4;print_title
  Y=5;print_ceph;print_space
  get_odf
}

function get_odf (){
  echo "[OCP]" >> $FILE
  X=12;print_title
  cat $FINAL_PATH/$OSD_HISTORY | grep -A200 " history:" | grep -Ei " version:|completion" >> $FILE && print_space
  X=13;print_title
  omc get jobs >> $FILE
  X=6;print_title
  cat $FINAL_PATH/namespaces/openshift-storage/oc_output/csv  >> $FILE && print_space
  X=16;print_title
  egrep -i "phase|flexiblescaling|cephdeviceclass|storageClassName|failureDomain:|mondatadirhostpath|creationTimestamp" $FINAL_PATH/namespaces/openshift-storage/oc_output/storagecluster.yaml >> $FILE 
  sed -n '/storageDeviceSets:/,$p' $FINAL_PATH/namespaces/openshift-storage/oc_output/storagecluster.yaml | grep -E "count: |replica: " >> $FILE && print_space
  X=7;print_title
  omc get deployments >> $FILE && print_space
  X=8;print_title
  omc get events | egrep "failed|error" >> $FILE
  X=9;print_title
  omc get pvc | head -n 1 >> $FILE
  omc get pvc |grep deviceset >> $FILE && print_space
  X=17;print_title
  omc get pods -o wide | egrep -v "Running|Completed" >> $FILE
  X=10;print_title
  echo -e "POD_NAME\tPVC\tPV\tNODE\tPATH\tSTATUS" >> $FILE
  omc get pods -l app=rook-ceph-osd -o 'custom-columns=NAME:.metadata.name,PVC:.spec.volumes.*.persistentVolumeClaim.claimName,PV:.spec.volumeName,NODE:.spec.nodeName,STATUS:.status.phase' --no-headers | \
   while read -r pod_name pvc_name node status; do
    if [ -n "$pvc_name" ] && [ "$pvc_name" != "N/A" ]; then
       pv_from_pvc=$(omc get pvc "$pvc_name" -o 'custom-columns=PV:.spec.volumeName' --no-headers 2>/dev/null)
       local_path=$(omc get pv "$pv_from_pvc" -o 'custom-columns=PV:.spec.local.path' --no-headers 2>/dev/null)
      if [ -n "$pv_from_pvc" ]; then
        echo -e "$pod_name\t$pvc_name\t$pv_from_pvc\t$node\t$local_path\t$status" >> $FILE
      else
        echo "  PV for $pvc_name: Not found"
      fi
    else
      echo "Skipping line (PVC name not found or N/A): $pod_name"
    fi
  done
  get_noobaa
}

function get_noobaa (){
  X=19;print_title
  omc get pods -l app=noobaa >> $FILE
  X=20;print_title
  omc get pvc -l app=noobaa >> $FILE
  X=21;print_title
  cat $FINAL_PATH/noobaa/raw_output/obc_list  >> $FILE && print_space
  vim $FILE
}

##########################Main#####################################
main_menu
