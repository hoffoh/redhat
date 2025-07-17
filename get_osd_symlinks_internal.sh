#!/bin/bash
get_osd_symlinks_map (){
clear;
{
echo -e "POD_NAME\tPVC_NAME\tPV_NAME\tNODE\tLOCAL_PATH\tSTATUS"
oc get pods -l app=rook-ceph-osd -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\t"}{.status.phase}{"\t"}{range .spec.volumes[*]}{.persistentVolumeClaim.claimName}{" "}{end}{"\n"}{end}' | \
while IFS=$'\t' read -r POD_NAME NODE_NAME POD_STATUS PVC_NAMES_str; do
  read -ra PVC_NAMES <<< "$PVC_NAMES_str"
  if [ ${#PVC_NAMES[@]} -eq 0 ] || [[ "${PVC_NAMES[0]}" == "" ]]; then
    PVC_NAME="N/A"
    pv_name="N/A"
    local_path="N/A"
    echo -e "$POD_NAME\t$PVC_NAME\t$pv_name\t$NODE_NAME\t$local_path\t$POD_STATUS"
  else
    for PVC_NAME in "${PVC_NAMES[@]}"; do
      if [ -n "$PVC_NAME" ]; then
        pv_name=$(oc get pvc "$PVC_NAME" -o jsonpath='{.spec.volumeName}' 2>/dev/null)
        local_path="N/A"
        if [ -n "$pv_name" ] && [ "$pv_name" != "N/A" ]; then
          local_path=$(oc get pv "$pv_name" -o jsonpath='{.spec.local.path}' 2>/dev/null)
          if [ -z "$local_path" ]; then
            local_path="N/A (Not Local PV)"
          fi
        fi
        echo -e "$POD_NAME\t$PVC_NAME\t${pv_name:-N/A}\t$NODE_NAME\t$local_path\t$POD_STATUS"
      fi
    done
  fi
done
} | column -t -s $'\t'
}
 
#Main
get_osd_symlinks_map
