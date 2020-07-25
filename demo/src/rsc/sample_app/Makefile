REGISTRY?=riccap
IMAGE?=autoscale-demo
TEMP_DIR:=$(shell mktemp -d)

VERSION?=v0.0.2

build:
	cp Dockerfile *.js $(TEMP_DIR)
	cd $(TEMP_DIR)
	docker build -t $(REGISTRY)/$(IMAGE):$(VERSION) $(TEMP_DIR)

push:
	$(MAKE) build
	docker push $(REGISTRY)/$(IMAGE):$(VERSION)
