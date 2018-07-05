cluster_name ?= dask-scipy
name ?= $(cluster_name)
config ?= pangeo-config.yaml
pangeo_version ?= v0.1.0-673e876

# GCP settings
project_id ?= dask-demo-182016
zone ?= us-central1-b
num_nodes ?= 3
machine_type ?= n1-standard-4
user ?= <google-account-email>

cluster:
	gcloud container clusters create $(cluster_name) \
	    --num-nodes=$(num_nodes) \
	    --machine-type=$(machine_type) \
	    --zone=$(zone) \
	    --enable-autorepair \
	    --enable-autoscaling --min-nodes=1 --max-nodes=200
	gcloud beta container node-pools create dask-scipy-preemptible \
	    --cluster=$(cluster_name) \
	    --preemptible \
	    --machine-type=$(machine_type) \
	    --zone=$(zone) \
	    --enable-autorepair \
	    --enable-autoscaling --min-nodes=1 --max-nodes=900 \
	    --node-taints preemptible=true:NoSchedule
	gcloud container clusters get-credentials $(cluster_name) --zone $(zone)

helm:
	kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(user)
	kubectl --namespace kube-system create sa tiller
	kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
	helm init --service-account tiller
	kubectl --namespace=kube-system patch deployment tiller-deploy --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'

jupyterhub:
	helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
	helm repo add pangeo https://pangeo-data.github.io/helm-chart/
	helm repo update
	@echo "Installing pangeo..."
	@helm install pangeo/pangeo \
		--version=$(pangeo_version) \
		--name=$(name) \
		--namespace=$(name) \
		-f $(config) \
		-f secret-config.yaml
		--set jupyterhub.proxy.secretToken="${JUPYTERHUB_PROXY_TOKEN}"


upgrade:
	@echo "Upgrading..."
	@helm upgrade $(name) pangeo/pangeo \
		--version=$(pangeo_version) \
		-f $(config) \
		-f secret-config.yaml \
		--set jupyterhub.proxy.secretToken="${JUPYTERHUB_PROXY_TOKEN}"

delete-helm:
	helm delete $(name) --purge
	kubectl delete namespace $(name)

delete-cluster:
	yes | gcloud container clusters delete $(cluster_name) --zone=$(zone)

shrink:
	gcloud container clusters resize $(cluster_name) --size=3 --zone=$(zone)

scale-up:
	gcloud container clusters resize $(cluster_name) --node-pool=dask-scipy-preemptible --size=720 --zone=$(zone)
	gcloud container clusters resize $(cluster_name) --node-pool=default-pool --size=80 --zone=$(zone)

docker-%: %/Dockerfile
	gcloud container builds submit \
		--tag gcr.io/$(project_id)/dask-tutorial-$(patsubst %/,%,$(dir $<)):$$(git rev-parse HEAD |cut -c1-6) \
		--timeout=1h \
		$(patsubst %/,%,$(dir $<))
	gcloud container images add-tag \
		gcr.io/$(project_id)/dask-tutorial-$(patsubst %/,%,$(dir $<)):$$(git rev-parse HEAD |cut -c1-6) \
		gcr.io/$(project_id)/dask-tutorial-$(patsubst %/,%,$(dir $<)):latest --quiet

commit:
	echo "$$(git rev-parse HEAD)"
