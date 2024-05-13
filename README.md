Fluent Developer Preview
========================

This repository contains scripts for .

Before running command you must do following steps:
- Buy a dedicated machine that have at least 8 dedicated CPU core and 32GB RAM (it runs 7 nodes)
- Make sure you have wildcard domain `*.example.com` set to your machine (use dedicated machine with public IP)

Private key with balance: `ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`

You can check Makefile to choose the most interesting commands, but if you just need to set up everything just run next command:

```bash
apt update
apt install -y build-essential socat
git clone https://github.com/fluentlabs-xyz/developer-preview --recursive
cd developer-preview
make install-docker
make install-acme
export CHAIN_ID=1337
export DOMAIN_NAME=<YOUR DOMAIN NAME>
make all
```

P.S: Variable `DOMAIN_NAME` should be set to your domain

Deployed services can be access though next endpoints:
- https://rpc.${DOMAIN_NAME} - Web3 RPC endpoint
- https://explorer.${DOMAIN_NAME} - Blockchain Explorer
- https://faucet.${DOMAIN_NAME} - Faucet
- https://staking.${DOMAIN_NAME} - Staking UI

If you want to run node w/o load balancer and SSL certificates then use next command:
```bash
CHAIN_ID=14000 make create-genesis start
```

Docker compose files exposes next ports:
- 30303 - bootnode endpoint
- 8545 - RPC endpoint
- 8546 - WS endpoint
- 3000 - faucet UI
- 7432 - blockscout PostgreSQL database
- 4000 - blockscout explorer
- 9000 - explorer