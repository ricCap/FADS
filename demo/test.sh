#!/bin/bash

set -euo pipefail


function log() {
  local message=$1
  echo "$(date +"%F,%T,%Z") $message"
}


log "Starting the test for the demo"
log "Make sure kubectl proxy is running"

readonly PROXY_URL="http://127.0.0.1:8001"
readonly CUSTOM_METRICS_URL="$PROXY_URL/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests_per_second"

readonly HTTP_REQUESTS_AUTOSCALING_THRESHOLD_MILLI=400

while true; do

  log "Retrieving VPA status"
  vpa=$(kubectl get vpa/sample-metrics-app-vpa -o json)
  vpa_status=$(echo $vpa | jq -r '.status.conditions[0].status')
  if [[ "$vpa_status" == "True" ]]; then
    vpa_recommendations=$(echo $vpa | jq -rc .)
    log "VPA recommendations: $vpa_recommendations"
  else
    log "The VPA is not ready yet, reccomendations will not be taken into account"
  fi

  log "Retrieving custom metrics"
  custom_metrics_response="$(curl -s $CUSTOM_METRICS_URL | jq -c .)"
  log "Custom metrics: $custom_metrics_response"

  log "Parsing custom metrics"
  while read -r item; do
    pod_name="$(echo $item | jq '.describedObject.name')"
    http_requests_per_second="$(echo $item | jq -r '.value')"
    log "POD $pod_name has value $http_requests_per_second for metric http_requests_per_second"
    value_milli="${http_requests_per_second/m/}"
    if [[ $value_milli -ge $HTTP_REQUESTS_AUTOSCALING_THRESHOLD_MILLI ]]; then
      log "Autoscaling pods to new resource limits: 300m"
      kubectl patch deployment sample-metrics-app --type json -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/limits/cpu", "value":"300m"}, {"op": "replace", "path": "/spec/template/spec/containers/0/resources/requests/cpu", "value":"300m"}]'
      break
    fi

  done <<< $(echo $custom_metrics_response | jq -c '.items[]')

  sleep 30
done
