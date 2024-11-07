.PHONY: check-env
check-env:
	export $(grep -v '^#' .env | xargs -d '\n')
	export CHAIN_ID=20993
ifndef DOMAIN_NAME
	$(error env DOMAIN_NAME is undefined)
endif
ifndef PRIVATE_KEY
	$(error env is undefined)
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
	envsubst < ./blockscout/envs/common-blockscout.template.env > ./blockscout/envs/common-blockscout.env
	envsubst < ./blockscout/envs/common-frontend.template.env > ./blockscout/envs/common-frontend.env
	echo "DOMAIN_NAME=${DOMAIN_NAME}\nPRIVATE_KEY=${PRIVATE_KEY}" > .env

.PHONY: start
start: check-env
	cat ./docker-compose.yaml | envsubst | docker-compose -f - pull
	cat ./docker-compose.yaml | envsubst | docker-compose -f - up -d --build

.PHONY: stop
stop: check-env
	docker compose stop

#.PHONY: init-genesis-state
#init-genesis-state:
	#docker run --platform=linux/amd64 -it -v "$(shell pwd):/devnet" --rm ghcr.io/fluentlabs-xyz/fluent --chain=dev init --datadir=/devnet/datadir

.PHONY: delete-state
delete-state:
	rm -rf ./datadir || true

.PHONY: blockscout
blockscout: check-env
	docker compose -f ./blockscout/geth.yml --project-name blockscout pull
	docker compose -f ./blockscout/geth.yml --project-name blockscout up -d

.PHONY: stop-blockscout
stop-blockscout: check-env
	docker compose -f ./blockscout/geth.yml --project-name blockscout down

.PHONY: reset-blockscout
reset-blockscout: check-env
	docker compose -f ./blockscout/geth.yml --project-name blockscout down || true
	rm -rf ./blockscout/services/blockscout-db-data || true
	rm -rf ./blockscout/services/logs || true
	rm -rf ./blockscout/services/redis-data || true
	rm -rf ./blockscout/services/stats-db-data || true
	docker compose -f ./blockscout/geth.yml --project-name blockscout up -d

.PHONY: reset
reset: stop delete-state start

.PHONY: all
all: install-docker install-acme cook start

.PHONY: clean-tx-pool
clean-tx-pool:
	docker stop developer-preview_fluent_1
	rm datadir/txpool-transactions-backup.rlp
	docker start developer-preview_fluent_1