SILENT = @

init:
	$(SILENT) cd src && chmod -R +x ./*sh
	$(SILENT) git clone https://github.com/kubernetes/autoscaler.git
	$(SILENT) git clone https://github.com/coreos/kube-prometheus.git

deploy-helm:
	$(SILENT) cd src && ./setup_helm.sh

deply-kube-prometheus:
	$(SILENT) cd src && ./setup_kube_prometheus.sh

test:
	$(SILENT) cd src && ./test.sh

clean:
	$(SILENT) rm -rf autoscaler kube-prometheus
