#!/bin/bash

set -euo pipefail

export HTTP_REQUESTS_AUTOSCALING_THRESHOLD_MILLI=300
readonly AUTOSCALING_PERIOD_SECONDS=10

readonly PROXY_URL="http://127.0.0.1:8001"
readonly CUSTOM_METRICS_URL="$PROXY_URL/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests_per_second"

function log() {
  local message=$1
  echo "$(date +"%F,%T,%Z") $message"
}

function collect_vpa_info(){
    vpa=$(kubectl get vpa/sample-metrics-app-vpa -o json)
    vpa_status=$(echo $vpa | jq -r '.status.conditions[0].status')
    if [[ "$vpa_status" == "True" ]]; then
      vpa_recommendations=$(echo $vpa | jq -rc .)
      log "VPA recommendations: $vpa_recommendations"
      return $vpa_recommendations
    else
      log "The VPA is not ready yet, reccomendations will not be taken into account"
    fi
}

function collect_custom_metrics(){
  custom_metrics_response="$(curl -s $CUSTOM_METRICS_URL)"
  log "Custom metrics: $custom_metrics_response"

  if [[ $(echo $custom_metrics_response | jq -e '.[]' &>/dev/null; echo $?) -ne 0 ]] ; then
    log "Could not retrieve custom metrics; retrying in $AUTOSCALING_PERIOD_SECONDS seconds"
  else
    log "Parsing custom metrics"
    while read -r item; do
      pod_name="$(echo $item | jq '.describedObject.name')"
      http_requests_per_second="$(echo $item | jq -r '.value')"
      if [[ -n "$pod_name" && -n "$http_requests_per_second" ]]; then
        log "POD $pod_name has value $http_requests_per_second for metric http_requests_per_second"
        value_millis="${http_requests_per_second/m/}"
        if [[ $value_millis -ge $HTTP_REQUESTS_AUTOSCALING_THRESHOLD_MILLI ]]; then
          log "Autoscaling pods to new resource limits: ${HTTP_REQUESTS_AUTOSCALING_THRESHOLD_MILLI}m"
          kubectl patch deployment sample-metrics-app --type json -p="[{\"op\": \"replace\", \"path\": \"/spec/template/spec/containers/0/resources/limits/cpu\", \"value\":\"${HTTP_REQUESTS_AUTOSCALING_THRESHOLD_MILLI}m\"}, {\"op\": \"replace\", \"path\": \"/spec/template/spec/containers/0/resources/requests/cpu\", \"value\":\"${HTTP_REQUESTS_AUTOSCALING_THRESHOLD_MILLI}m\"}]"
          break
        fi
      else
        log "No metric named \"http_requests_per_second; retrying in $AUTOSCALING_PERIOD_SECONDS seconds"
      fi
    done <<< $(echo $custom_metrics_response | jq -c '.items[]')
  fi
}

function main() {

  log "Starting the test for the demo"

  log "Starting kubectl proxy in a subprocess"
  kubectl proxy &

  while true; do

    log "Retrieving VPA recommendations"
    vpa_recommendations=$(collect_vpa_info)

    log "Retrieving custom metrics"
    collect_custom_metrics

    sleep $AUTOSCALING_PERIOD_SECONDS
    HTTP_REQUESTS_AUTOSCALING_THRESHOLD_MILLI=$((HTTP_REQUESTS_AUTOSCALING_THRESHOLD_MILLI + 50))
  done

}

main
