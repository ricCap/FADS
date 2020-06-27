#!/bin/bash
set -euo pipefail

export DEMO_HOME="$(pwd)"

minikube delete
minikube start --kubernetes-version=v1.18.3 --memory=3g --bootstrapper=kubeadm \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.address=0.0.0.0 \
--extra-config=controller-manager.address=0.0.0.0

#git clone https://github.com/coreos/kube-prometheus.git
minikube addons disable metrics-server

kubectl apply -f $DEMO_HOME/kube-prometheus/manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl apply -f $DEMO_HOME/kube-prometheus/manifests/

# Register our API server to the custom metrics API server
kubectl apply -f $DEMO_HOME/custom-metrics.yaml

# Deploy our sample application
kubectl apply -f $DEMO_HOME/sample-metrics-app.yaml
kubectl apply -f $DEMO_HOME/service-monitor.yaml
