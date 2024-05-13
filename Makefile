.PHONY: check-env
check-env:
	export CHAIN_ID=1337
ifndef DOMAIN_NAME
	$(warning env DOMAIN_NAME is undefined)
endif

.PHONY: install-docker
install-docker:
	bash ./scripts/install-docker.bash

.PHONY: install-acme
install-acme:
	curl https://get.acme.sh | sh -s email=my@example.com
	bash ./scripts/issue-cert.bash

.PHONY: cook
cook: check-env
	envsubstr '${DOMAIN_NAME}' < ./docker-compose.yaml > ./docker-compose.yaml
	envsubstr '${DOMAIN_NAME}' < ./blockscout/envs/common-frontend.env > ./blockscout/envs/common-frontend.env
	envsubstr '${DOMAIN_NAME}' < ./blockscout/envs/common-blockscout.env > ./blockscout/envs/common-blockscout.env
	envsubstr '${DOMAIN_NAME}' < ./nginx/nginx.conf > ./nginx/nginx.conf

.PHONY: start
start:
	cat ./docker-compose.yaml | envsubst | docker-compose -f - pull
	cat ./docker-compose.yaml | envsubst | docker-compose -f - up -d

.PHONY: stop
stop:
	docker compose stop

.PHONY: init-genesis-state
init-genesis-state:
	docker run --platform=linux/amd64 -it -v "$(shell pwd):/devnet" --rm ghcr.io/fluentlabs-xyz/fluent --chain=dev init --datadir=/devnet/datadir

.PHONY: delete-state
delete-state:
	rm -rf ./datadir || true

.PHONY: reset-blockscout
reset-blockscout:
	docker compose -f ./blockscout/geth.yml down || true
	rm -rf ./blockscout/services/blockscout-db-data || true
	rm -rf ./blockscout/services/logs || true
	rm -rf ./blockscout/services/redis-data || true
	rm -rf ./blockscout/services/stats-db-data || true
	docker compose -f ./blockscout/geth.yml up -d

reset: stop delete-state init-genesis-state

all: install-docker install-acme cook start