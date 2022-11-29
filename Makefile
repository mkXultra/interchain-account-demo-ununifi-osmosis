#!/usr/bin/make -f
PACKAGES=$(shell go list ./...)
DOCKER := $(shell which docker)
DOCKER_BUF := $(DOCKER) run --rm -v $(CURDIR):/workspace --workdir /workspace bufbuild/buf:1.0.0-rc8

###############################################################################
###                           Install                                       ###
###############################################################################
submod-update: 
		@echo "--> update submodule"
		@git submodule update --init --recursive 

install-osmosis: submod-update
		@echo "--> Installing osmosis chain"
		@cd osmosis&& make install

install-ununifi: submod-update
		@echo "--> Installing ununifi chain"
		@cd ununifi&& make install

install: install-ununifi install-osmosis
		@echo "--> Installing chain"


###############################################################################
###                                Initialize                               ###
###############################################################################

init-hermes: kill-dev install
	@echo "Initializing both blockchains..."
	./network/init.sh
	./network/start.sh
	@echo "Initializing relayer..." 
	./network/hermes/restore-keys.sh
	./network/hermes/create-conn.sh

init-golang-rly: kill-dev install
	@echo "Initializing both blockchains..."
	./network/init.sh
	./network/start.sh
	@echo "Initializing relayer..."
	./network/relayer/interchain-acc-config/rly-init.sh

start-hermes:
	./network/hermes/start.sh

start-golang-rly:
	./network/relayer/interchain-acc-config/rly-start.sh

kill-dev:
	@echo "Killing ununifid and removing previous data"
	-@rm -rf ./data
	-@killall ununifid 2>/dev/null
	-@killall osmosisd 2>/dev/null

start:init-hermes start-hermes
	@echo "init then start"

create-pools:
	@echo "create pools"
	./scripts/ibc-transfer.sh
	./scripts/setup_superfluid.sh
	@echo "created stake/uosmo uguu/uosmo pools"
