# Prerequisites

This tutorial assumes that you have Minikube and Helm insalled on your machine. We also use yq for yaml parsing

## Clone necessary repositories

```
git clone https://github.com/coreos/kube-prometheus.git
git clone https://github.com/kubernetes/autoscaler.git
```

## Get the stable repository

`helm repo add stable <https://kubernetes-charts.storage.googleapis.com>`

## Test

For a fast solution just copy-paste in a terminal the code below

```
TEST_URL='/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests_per_second'
APISERVER=$(kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " ")
SECRET_NAME=$(kubectl get secrets | grep ^default | cut -f1 -d ' ')
TOKEN=$(kubectl describe secret $SECRET_NAME | grep -E '^token' | cut -f2 -d':' | tr -d " ")

curl $APISERVER/$TEST_URL --header "Authorization: Bearer $TOKEN" --insecure
```

or run

```
kubectl proxy
```

and then use either curl

`curl $API_URL/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests_per_second` or go to a browser and paste the url. $API_URL is the url that you receive as output of the kubectl proxy command.

The output should be a valid JSON with a structure similar to this

```json
{
  "kind": "MetricValueList",
  "apiVersion": "custom.metrics.k8s.io/v1beta1",
  "metadata": {
    "selfLink": "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/%2A/http_requests_per_second"
  },
  "items": [
    {
      "describedObject": {
        "kind": "Pod",
        "namespace": "default",
        "name": "sample-metrics-app-7d588f67f9-p7gwj",
        "apiVersion": "/v1"
      },
      "metricName": "http_requests_per_second",
      "timestamp": "2020-07-05T06:43:58Z",
      "value": "433m",
      "selector": null
    },
    {
      "describedObject": {
        "kind": "Pod",
        "namespace": "default",
        "name": "sample-metrics-app-7d588f67f9-pstw5",
        "apiVersion": "/v1"
      },
      "metricName": "http_requests_per_second",
      "timestamp": "2020-07-05T06:43:58Z",
      "value": "433m",
      "selector": null
    }
  ]
}
```

You can find more info about how to access a K8s cluster [here](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/).

To check that the VPA is working simply run `kubectl describe vpa`.
