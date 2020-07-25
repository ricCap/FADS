#!/bin/bash
set -euo pipefail

readonly DEMO_HOME="$(pwd)"

minikube delete
minikube start --kubernetes-version=v1.18.3 --memory=3g --bootstrapper=kubeadm \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.address=0.0.0.0 \
--extra-config=controller-manager.address=0.0.0.0

# https://github.com/coreos/kube-prometheus.git
minikube addons disable metrics-server

# Deploy kube-prometheus
kubectl apply -f kube-prometheus/manifests/setup
sleep 5;
kubectl apply -f kube-prometheus/manifests/

# Patch the configmap of the Prometheus adapter of kube-prometheus with
# our custom rules
kubectl apply -f rsc/kube-prometheus-adapter-config.yaml

# Deploy our sample application
kubectl apply -f rsc/sample-metrics-app.yaml

# Deploy VPA
cd $DEMO_HOME/autoscaler/vertical-pod-autoscaler && ./hack/vpa-up.sh && cd $DEMO_HOME
kubectl create -f rsc/vpa.yaml

# Watch for all resources to be created correctly
watch kubectl get po -A
