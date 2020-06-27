#!/bin/bash
set -euo pipefail

export DEMO_HOME="$(pwd)"

# FIXME kubelet.authentication-token-webhook and kubelet.authentication-token-mode are
# require for the extension of the

minikube delete
minikube start --kubernetes-version=v1.18.3 --memory=3g --bootstrapper=kubeadm \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.address=0.0.0.0 \
--extra-config=controller-manager.address=0.0.0.0

# Get the stable repository
helm repo add stable <https://kubernetes-charts.storage.googleapis.com>

# Deploy Prometheus using Helm chart
helm install demo stable/prometheus
# helm delete demo

# Deploy Prometheus adapter
# https://github.com/directxman12/k8s-prometheus-adapter
helm install demo-adapter stable/prometheus-adapter \
  --set prometheus.url="http://demo-prometheus-server.default.svc" \
  --set prometheus.port="80" \
  --set metricsRelistInterval="30s"
# helm delete demo-adapter

# Deploy our sample application
kubectl apply -f sample-metrics-app.yaml
