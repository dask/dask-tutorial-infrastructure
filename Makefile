cluster_name = dask-pycon
name = $(cluster_name)
zone = us-central1-b
config = pangeo-config.yaml
pangeo_version = v0.1.0-673e876

cluster:
	gcloud container clusters create $(cluster_name) \
    --num-nodes=3 \
    --machine-type=n1-standard-2 \
    --zone=$(zone)

helm:
	kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=taugspurger@anaconda.com
	kubectl --namespace kube-system create sa tiller
	kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
	helm init --service-account tiller
	kubectl --namespace=kube-system patch deployment tiller-deploy --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'

jupyterhub:
	helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
	helm repo add pangeo https://pangeo-data.github.io/helm-chart/
	helm repo update
	helm install pangeo/pangeo \
		--version=$(pangeo_version) \
		--name=$(name) \
		--namespace=$(name) \
		-f $(config)

upgrade:
	helm upgrade $(name) pangeo/pangeo --version=$(pangeo_version) -f $(config)

delete-helm:
	helm delete $(name) --purge
	kubectl delete namespace $(name)

delete-cluster:
	gcloud container clusters delete $(cluster_name) --zone=$(zone)

shrink:
	gcloud container clusters resize $(cluster_name) --size=1 --zone=$(zone)
