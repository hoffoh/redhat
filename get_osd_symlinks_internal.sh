#!/bin/bash
# NOTE: Important: This script will collect the data from the "omc" cli current case assigned

# Function
get_osd_symlinks_map (){
clear
echo ''
omc project
echo ''
{
echo -e "POD_NAME\tPVC\tPV\tNODE\tPATH\tSTATUS"
omc get pods -l app=rook-ceph-osd -o 'custom-columns=NAME:.metadata.name,PVC:.spec.volumes.*.persistentVolumeClaim.claimName,PV:.spec.volumeName,NODE:.spec.nodeName,STATUS:.status.phase' --no-headers | \
 while read -r pod_name pvc_name node status; do
  if [ -n "$pvc_name" ] && [ "$pvc_name" != "N/A" ]; then
     pv_from_pvc=$(omc get pvc "$pvc_name" -o 'custom-columns=PV:.spec.volumeName' --no-headers 2>/dev/null)
     local_path=$(omc get pv "$pv_from_pvc" -o 'custom-columns=PV:.spec.local.path' --no-headers 2>/dev/null)
    if [ -n "$pv_from_pvc" ]; then
      echo -e "$pod_name\t$pvc_name\t$pv_from_pvc\t$node\t$local_path\t$status"
    else
      echo "  PV for $pvc_name: Not found"
    fi
  else
    echo "Skipping line (PVC name not found or N/A): $pod_name"
  fi
  echo "" # Add a blank line for readability
done
} | column -t -s $'\t'
}

#Main
get_osd_symlinks_map

