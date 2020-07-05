#!/bin/bash
set -euo pipefail

minikube delete
minikube start --kubernetes-version=v1.18.3 --memory=3g --bootstrapper=kubeadm \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.address=0.0.0.0 \
--extra-config=controller-manager.address=0.0.0.0

# https://github.com/coreos/kube-prometheus.git
minikube addons disable metrics-server

kubectl apply -f kube-prometheus/manifests/setup
sleep 5;
kubectl apply -f kube-prometheus/manifests/

# Deploy Prometheus adapter
# https://github.com/directxman12/k8s-prometheus-adapter
helm install demo-adapter stable/prometheus-adapter \
  --set prometheus.url="http://prometheus-k8s.monitoring.svc" \
  --set metricsRelistInterval="30s" \
  -f "adapter-config.yaml"
# helm delete demo-adapter

# Deploy our sample application
kubectl apply -f sample-metrics-app.yaml

# Deploy the service monitor used to scrape the metrics
#kubectl apply -f demo-kube-prometheus/service-monitor.yaml

watch kubectl get po -A
