`kubectl apply -f <https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml>`

# <https://github.com/helm/charts>

```
helm repo add stable <https://kubernetes-charts.storage.googleapis.com>

helm install prometheus stable/prometheus

helm install prometheus-adapter stable/prometheus-adapter
```

docker network prune
