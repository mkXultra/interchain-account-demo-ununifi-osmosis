#!/bin/bash
# this script runs under the assumption that a three-validator environment is running on your local machine(multinode-local-testnet.sh)
# this script would do basic setup that has to be achieved to actual superfluid staking
# prior to running this script, have the following json file in the directory running this script
#
# stake-uosmo.json
# {
# 	"weights": "5stake,5uosmo",
# 	"initial-deposit": "1000000stake,1000000uosmo",
# 	"swap-fee": "0.01",
# 	"exit-fee": "0.01",
# 	"future-governor": "168h"
# }
SCRIPT_DIR=$(cd $(dirname $0); pwd)
. $SCRIPT_DIR/variables.sh

# create pool
$BINARY_ICA_HOST tx gamm create-pool --pool-file=$SCRIPT_DIR/stake-uosmo.json $EX_USER --keyring-backend=test --chain-id=$CHAINID_2 --yes $HOME_LOCATION --broadcast-mode=block
$BINARY_ICA_HOST tx gamm create-pool --pool-file=$SCRIPT_DIR/uguu-uosmo.json $EX_USER --keyring-backend=test --chain-id=$CHAINID_2 --yes $HOME_LOCATION --broadcast-mode=block
# sleep 7
$BINARY_ICA_HOST q gamm pools

# test swap in pool created
# $BINARY_ICA_HOST tx gamm swap-exact-amount-in 100000uosmo 50000 --swap-route-pool-ids=1 --swap-route-denoms=stake $EX_USER --keyring-backend=test --chain-id=$CHAINID_2 --yes $HOME_LOCATION
# swap uosmo to stake
$BINARY_ICA_HOST tx gamm swap-exact-amount-in 100000uosmo 50000 --swap-route-pool-ids=1 --swap-route-denoms=stake $EX_USER --keyring-backend=test --chain-id=$CHAINID_2 --yes $HOME_LOCATION --broadcast-mode=block
# swap stake to uosmo
$BINARY_ICA_HOST tx gamm swap-exact-amount-in 100000stake 50000 --swap-route-pool-ids=1 --swap-route-denoms=uosmo $EX_USER --keyring-backend=test --chain-id=$CHAINID_2 --yes $HOME_LOCATION --broadcast-mode=block
# swap stake to uosmo
$BINARY_ICA_HOST tx gamm swap-exact-amount-in 100000stake 50000 --swap-route-pool-ids=1 --swap-route-denoms=uosmo --from=wallet3 --keyring-backend=test --chain-id=$CHAINID_2 --yes $HOME_LOCATION --broadcast-mode=block
# swap uosmo to uosmo
$BINARY_ICA_HOST tx gamm swap-exact-amount-in 88567uosmo 5000 --swap-route-pool-ids=2 --swap-route-denoms=ibc/737D702F5E4DFE7A3A27DEEB16C5225C880F1A02AE637F67C194F9074BCD6ED8 --from=wallet3 --keyring-backend=test --chain-id=$CHAINID_2 --yes $HOME_LOCATION --broadcast-mode=block

sleep 7

# # create a lock up with lockable duration 360h
# $BINARY_ICA_HOST tx lockup lock-tokens 10000000000000000000gamm/pool/1 --duration=360h $EX_USER --keyring-backend=test --chain-id=$CHAINID_2 --broadcast-mode=block --yes $HOME_LOCATION
# sleep 7

# # submit and pass proposal for superfluid
# $BINARY_ICA_HOST tx gov submit-proposal set-superfluid-assets-proposal --title="set superfluid assets" --description="set superfluid assets description" --superfluid-assets="gamm/pool/1" --deposit=10000000uosmo --from=validator1 --chain-id=testing --keyring-backend=test --broadcast-mode=block --yes --home=$HOME/.osmosisd/validator1
# sleep 7

# $BINARY_ICA_HOST tx gov deposit 1 10000000stake $EX_USER --keyring-backend=test --chain-id=$CHAINID_2 --broadcast-mode=block --yes $HOME_LOCATION
# sleep 7

# $BINARY_ICA_HOST tx gov vote 1 yes --from=validator1 --keyring-backend=test --chain-id=testing --yes --home=$HOME/.osmosisd/validator1
# sleep 7
# $BINARY_ICA_HOST tx gov vote 1 yes --from=validator2 --keyring-backend=test --chain-id=testing --yes --home=$HOME/.osmosisd/validator2
# sleep 7
