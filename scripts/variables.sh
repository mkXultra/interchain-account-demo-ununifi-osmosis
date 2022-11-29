#!/bin/bash

BINARY=ununifid
BINARY_ICA_HOST=osmosisd
CHAIN_DIR=./data
CHAINID_1=test-1
CHAINID_2=test-2
BINARY_MAIN_TOKEN=uguu
# BINARY_MAIN_TOKEN=stake

export WALLET_1=$(ununifid keys show wallet1 -a --keyring-backend test --home ./data/test-1) && echo $WALLET_1;
export WALLET_2=$(ununifid keys show wallet2 -a --keyring-backend test --home ./data/test-1) && echo $WALLET_2;
export WALLET_3=$(osmosisd keys show wallet3 -a --keyring-backend test --home ./data/test-2) && echo $WALLET_3;
export WALLET_4=$(osmosisd keys show wallet4 -a --keyring-backend test --home ./data/test-2) && echo $WALLET_4;
export VAL2=$(osmosisd keys show val2 -a --keyring-backend test --home ./data/test-2) && echo $VAL2;

P2PPORT_1=16656
P2PPORT_2=26656
RPCPORT_1=16657
RPCPORT_2=26657
RESTPORT_1=1316
RESTPORT_2=1317
ROSETTA_1=8080
ROSETTA_2=8081

HOME_LOCATION=--home=$CHAIN_DIR/$CHAINID_2
EX_USER=--from=val2
VOTE_USER=--from=validator1