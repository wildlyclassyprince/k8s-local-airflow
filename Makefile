NAMESPACE := airflow
RELEASE_NAME := airflow
VALUES_FILE := values.yaml
WEBSERVER_PORT := 8080

.PHONY: help install update port-forward clean check-context logs status describe test-connection bounce

test:
	@echo "this is a test"
help:
	@echo 'Usage:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort  | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

check-context:
	@if [ "$$(kubectl config current-context)" != "docker-desktop" ]; then echo "Error: not in docker-desktop context"; exit 1; fi

install: check-context
	kubectl create namespace $(NAMESPACE)
	kubectl create configmap airflow-requirements --from-file=./requirements.txt --namespace $(NAMESPACE)
	helm dependency update ./
	helm upgrade --install $(RELEASE_NAME) ./ -f $(VALUES_FILE) --namespace $(NAMESPACE)

update:
	helm dependency update ./
	helm upgrade $(RELEASE_NAME) ./ -f $(VALUES_FILE) --namespace $(NAMESPACE)

port-forward:
	kubectl port-forward svc/$(RELEASE_NAME)-webserver $(WEBSERVER_PORT):$(WEBSERVER_PORT) --namespace $(NAMESPACE)

logs:
	kubectl logs -f deployment/$(RELEASE_NAME)-webserver --namespace $(NAMESPACE)

clean:
	helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE)
	kubectl delete namespace $(NAMESPACE)

status:
	kubectl get pods -n $(NAMESPACE)

describe:
	@echo "=== Pods ==="
	kubectl describe pods -n $(NAMESPACE)
	@echo "\n=== Services ==="
	kubectl describe services -n $(NAMESPACE)
	@echo "\n=== Deployment ==="
	kubectl describe deployments -n $(NAMESPACE)

test-connection:
	kubectl exec -it $$(kubectl get pods -n $(NAMESPACE) -l component=webserver -o jsonpath='{.items[0].metadata.name}') -n $(NAMESPACE) -- airflow db check

bounce: clean install

.DEFAULT_GOAL := help
