.PHONE: install-docker install-acme start check-env start stop reset-explorer delete-state reset all

check-env:
	export CHAIN_ID=1337
#ifndef DOMAIN_NAME
#	$(warning env DOMAIN_NAME is undefined)
#endif
#ifndef CHAIN_ID
#	$(error env CHAIN_ID is undefined)
#endif

install-docker:
	bash ./scripts/install-docker.bash

install-acme:
	curl https://get.acme.sh || true
	bash ./scripts/issue-cert.bash

start: check-env
	cat ./docker-compose.yaml | envsubst | docker-compose -f - pull
	cat ./docker-compose.yaml | envsubst | docker-compose -f - up -d

stop: check-env
	docker compose stop

reset-explorer: check-env stop
	docker compose stop
	rm -rf ./datadir/blockscout
	cat ./docker-compose.yaml | envsubst | docker-compose -f - up -d

init-genesis-state: check-env
	docker run --platform=linux/amd64 -it -v "$(shell pwd):/devnet" --rm ghcr.io/fluentlabs-xyz/fluent --chain=dev init --datadir=/devnet/datadir

delete-state:
	rm -rf ./datadir

reset-blockscout: check-env
	docker compose -f ./blockscout/geth.yml down || true
	rm -rf ./blockscout/services/blockscout-db-data || true
	rm -rf ./blockscout/services/logs || true
	rm -rf ./blockscout/services/redis-data || true
	rm -rf ./blockscout/services/stats-db-data || true
	docker compose -f ./blockscout/geth.yml up -d

reset: check-env stop delete-state init-genesis-state

all: check-env start