#!/bin/bash
set -euo pipefail

minikube delete
minikube start --kubernetes-version=v1.18.3 --memory=3g --bootstrapper=kubeadm \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.address=0.0.0.0 \
--extra-config=controller-manager.address=0.0.0.0

# Deploy Prometheus using Helm chart
helm install demo stable/prometheus
# helm delete demo

# Deploy Prometheus adapter
# https://github.com/directxman12/k8s-prometheus-adapter
helm install demo-adapter stable/prometheus-adapter \
  --set prometheus.url="http://demo-prometheus-server.default.svc" \
  --set prometheus.port="80" \
  --set metricsRelistInterval="30s" \
  --set v="10" \
  --set rules.custom="adapter-config.yaml"
# helm delete demo-adapter

# Deploy our sample application
kubectl apply -f sample-metrics-app.yaml

watch kubectl get po -A
