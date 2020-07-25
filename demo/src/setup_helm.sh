#!/bin/bash
set -euo pipefail

readonly DEMO_HOME="$(pwd)"

minikube delete
minikube start --kubernetes-version=v1.18.3 --memory=3g --bootstrapper=kubeadm \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.address=0.0.0.0 \
--extra-config=controller-manager.address=0.0.0.0

# Deploy Prometheus using Helm chart
helm install demo stable/prometheus

# Deploy Prometheus adapter
# https://github.com/directxman12/k8s-prometheus-adapter
helm install demo-adapter stable/prometheus-adapter \
  --set prometheus.url="http://demo-prometheus-server.default.svc" \
  --set prometheus.port="80" \
  --set metricsRelistInterval="30s" \
  -f "rsc/adapter-config.yaml"

# Deploy our sample application
kubectl apply -f rsc/sample-metrics-app.yaml

# Deploy the metrics server
minikube addons enable metrics-server
# alternatively: kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml

# Deploy VPA
cd $DEMO_HOME/autoscaler/vertical-pod-autoscaler && ./hack/vpa-up.sh && cd $DEMO_HOME
kubectl create -f rsc/vpa.yaml

# Watch for all resources to be created correctly
watch kubectl get po -A
