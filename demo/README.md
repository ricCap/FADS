# Towards FogAtlasDynamicScheduler

Our wish with this tutorial is to present the general idea of what FogAtlasDynamicScheduler will become.

FogAtlasDynamicScheduler will allow dynamic vertical autoscaling on pods based on custom metrics (and possibly, recommended actions) exposed by the pods themselves. A complete workflow might be like this:

- pod exposes custom metric and recommended action on its /metrics endpoint (e.g. `requests_5xx_error_rate, "lt", "3%", "SCALE_VERTICAL"`)
- the metrics are scraped by Prometheus and exposed on the K8s API custom.metrics.k8s.io
- FADS reads the metrics from K8s API and analyses whether the condition is met
- (optional) FADS collects recommendations on resource metrics from Vertical Pod Autoscaler
- If `requests_5xx_error_rate > 0.03` then: "SCALE_VERTICAL"

The tutorial quickly shows how to expose pod-generated custom metrics (scraped by Prometheus on the pods /metrics endpoint) to custom.metrics.k8s.io. We will use the [prometheus adapter](https://github.com/DirectXMan12/k8s-prometheus-adapter) as our implementation for the custom metrics API during this tutorial. If you want to implement your own version you should check out this [repository](https://github.com/kubernetes-sigs/custom-metrics-apiserver), which gives you all the boilerplate code to set you up as quick as possible.

The material in this tutorial is inspired by and liberally taken from these two examples [1](https://github.com/luxas/kubeadm-workshop) and [2]() by [Lucas Käldström](https://github.com/luxas).

The demo has been tested in the following environments:

> Ubuntu 20.04

There are two scripts `setup_helm.sh` and `setup_kube_prometheus.sh`. The main difference between the two is the way Prometheus is deployed, either via the Helm chart or through the managed kube_prometheus project. If you are not sure what the difference is, or you have never deployed prometheus before, follow the kube_prometheus path. The Helm solution is presented since in the environment where FADS will operate Prometheus is deployed usin the Helm chart.

# Prerequisites

This tutorial assumes that you have [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) installed. [kind](https://kind.sigs.k8s.io/docs/user/configuration/) can also be used, though the configuration changes (you should deploy the metrics server through the YAML file and not as an addon) will not be covered here.

The helm walkthough requires you to have [Helm](https://helm.sh/docs/intro/install/) insalled.

- Clone the necessary repositories

  ```
  git clone https://github.com/coreos/kube-prometheus.git (for setup_kube_prometheus.sh)
  git clone https://github.com/kubernetes/autoscaler.git (for both)
  ```

- Get the stable repository (for setup_help.sh)

`helm repo add stable <https://kubernetes-charts.storage.googleapis.com>`

## Run

> **Note that the system takes ~10m to spin up and to serve the custom metrics at custom.metrics.k8s.io**

Depending on what you chose above, run either `./setup-helm.sh` or `./setup-kube-prometheus.sh`. The interactive command `watch kubectl get po -A` is run at the end of both scripts, allowing you to check the system starting up. Please wait till all pods enter the Running state before moving to the test phase.

Here we give a brief description of what the two scripts do:

### setup_helm.sh

- Start Minikube
- Deploy Prometheus using the Helm chart
- Deploy the Prometheus Adapter
- Deploy our sample application
- Deploy the metrics server (by enabling the Minikube addon)
- Deploy a Vertical Pod Autoscaler

### setup_kube_prometheus.sh

- Start Minikube
- Disable the metrics server Minikube addon (the metrics server is part of the kube-prometheus project)
- Deploy kube-prometheus
- Deploy the Prometheus Adapter
- Deploy our sample application
- Deploy a Vertical Pod Autoscaler

## Test

To check that everything is working we will try to see whether the metric exposed by our application (i.e., http_requests_total) has been exported to the k8s custom.metrics.k8s.io endpoint.

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

To check that the VPA is working simply run `kubectl describe vpa`. To check the current resources limits/requests for our sample application run `kubectl get deploy sample-metrics-app -o json | jq '.spec.template.spec.containers[0].resources'`.

To simulate how FADS will work, run the `test.sh` command once the metrics are exposed at custom.metrics.k8s.io. Re-run the command `kubectl get deploy sample-metrics-app -o json | jq '.spec.template.spec.containers[0].resources'` and see that the resources have been scaled.

The script increases the CPU limits/requests of the Deployment until the condition is met. Modify `AUTOSCALING_PERIOD_SECONDS` ro speed up/down the autoscaling.
