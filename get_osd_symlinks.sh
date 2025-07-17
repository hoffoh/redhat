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
    omc get pods -l app=rook-ceph-osd -o 'custom-columns=NAME:.metadata.name,PVC:.spec.volumes.*.persistentVolumeClaim.claimName,NODE:.spec.nodeName,STATUS:.status.phase' --no-headers | \ 
    while read -r pod_name all_pvc_names node status; do
      read -ra pvc_array <<< "$all_pvc_names"
      if [ ${#pvc_array[@]} -eq 0 ] || [[ "${pvc_array[0]}" == "" ]]; then
        echo -e "$pod_name\tN/A\tN/A\t$node\tN/A\t$status"
      else
        for current_pvc_name in "${pvc_array[@]}"; do
          if [ -n "$current_pvc_name" ]; then
            pv_from_pvc=$(omc get pvc "$current_pvc_name" -o 'custom-columns=PV:.spec.volumeName' --no-headers 2>/dev/null)
            local_path=$(omc get pv "$pv_from_pvc" -o 'custom-columns=PV:.spec.local.path' --no-headers 2>/dev/null)
            pv_from_pvc_display="${pv_from_pvc:-N/A}"
            local_path_display="${local_path:-N/A}" 
            if [ "$local_path_display" == "N/A" ] && [ "$pv_from_pvc_display" != "N/A" ]; then
                if ! omc get pv "$pv_from_pvc" -o jsonpath='{.spec.local}' &>/dev/null; then
                    local_path_display="N/A (Not Local PV)"
                fi
            fi
            echo -e "$pod_name\t$current_pvc_name\t$pv_from_pvc_display\t$node\t$local_path_display\t$status"
          fi
        done
      fi  
    done
  } | column -t -s $'\t' # Pipe the entire block to column for formatting
}
 
# Main script execution
get_osd_symlinks_map
