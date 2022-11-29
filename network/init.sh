#!/bin/bash

# Load shell variables
SCRIPT_DIR=$(cd $(dirname $0); pwd)
. $SCRIPT_DIR/variables.sh

# Stop if it is already running 
if pgrep -x "$BINARY" >/dev/null; then
    echo "Terminating $BINARY..."
    killall $BINARY
fi

echo "Removing previous data..."
rm -rf $CHAIN_DIR/$CHAINID_1 &> /dev/null
rm -rf $CHAIN_DIR/$CHAINID_2 &> /dev/null

# Add directories for both chains, exit if an error occurs
if ! mkdir -p $CHAIN_DIR/$CHAINID_1 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi

if ! mkdir -p $CHAIN_DIR/$CHAINID_2 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi

echo "Initializing $CHAINID_1..."
echo "Initializing $CHAINID_2..."
$BINARY init test --home $CHAIN_DIR/$CHAINID_1 --chain-id=$CHAINID_1
$BINARY_ICA_HOST init test --home $CHAIN_DIR/$CHAINID_2 --chain-id=$CHAINID_2

# change main token
sed -i -e 's/\bstake\b/'$BINARY_MAIN_TOKEN'/g' $CHAIN_DIR/$CHAINID_1/config/genesis.json

echo "Adding genesis accounts..."
echo $VAL_MNEMONIC_1 | $BINARY keys add val1 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-backend=test
echo $VAL_MNEMONIC_2 | $BINARY_ICA_HOST keys add val2 --home $CHAIN_DIR/$CHAINID_2 --recover --keyring-backend=test
echo $WALLET_MNEMONIC_1 | $BINARY keys add wallet1 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-backend=test
echo $WALLET_MNEMONIC_2 | $BINARY keys add wallet2 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-backend=test
echo $WALLET_MNEMONIC_3 | $BINARY_ICA_HOST keys add wallet3 --home $CHAIN_DIR/$CHAINID_2 --recover --keyring-backend=test
echo $WALLET_MNEMONIC_4 | $BINARY_ICA_HOST keys add wallet4 --home $CHAIN_DIR/$CHAINID_2 --recover --keyring-backend=test
echo $RLY_MNEMONIC_1 | $BINARY keys add rly1 --home $CHAIN_DIR/$CHAINID_1 --recover --keyring-backend=test 
echo $RLY_MNEMONIC_2 | $BINARY_ICA_HOST keys add rly2 --home $CHAIN_DIR/$CHAINID_2 --recover --keyring-backend=test 

$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID_1 keys show val1 --keyring-backend test -a) 100000000000$BINARY_MAIN_TOKEN --home $CHAIN_DIR/$CHAINID_1
$BINARY_ICA_HOST add-genesis-account $($BINARY_ICA_HOST --home $CHAIN_DIR/$CHAINID_2 keys show val2 --keyring-backend test -a) 100000000000stake,100000000000uosmo  --home $CHAIN_DIR/$CHAINID_2
$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID_1 keys show wallet1 --keyring-backend test -a) 100000000000$BINARY_MAIN_TOKEN  --home $CHAIN_DIR/$CHAINID_1
$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID_1 keys show wallet2 --keyring-backend test -a) 100000000000$BINARY_MAIN_TOKEN  --home $CHAIN_DIR/$CHAINID_1
$BINARY_ICA_HOST add-genesis-account $($BINARY_ICA_HOST --home $CHAIN_DIR/$CHAINID_2 keys show wallet3 --keyring-backend test -a) 100000000000stake  --home $CHAIN_DIR/$CHAINID_2
$BINARY_ICA_HOST add-genesis-account $($BINARY_ICA_HOST --home $CHAIN_DIR/$CHAINID_2 keys show wallet4 --keyring-backend test -a) 100000000000stake,100000000000uosmo  --home $CHAIN_DIR/$CHAINID_2
$BINARY add-genesis-account $($BINARY --home $CHAIN_DIR/$CHAINID_1 keys show rly1 --keyring-backend test -a) 100000000000$BINARY_MAIN_TOKEN  --home $CHAIN_DIR/$CHAINID_1
$BINARY_ICA_HOST add-genesis-account $($BINARY_ICA_HOST --home $CHAIN_DIR/$CHAINID_2 keys show rly2 --keyring-backend test -a) 100000000000stake,100000000000uosmo  --home $CHAIN_DIR/$CHAINID_2

echo "Creating and collecting gentx..."
$BINARY gentx val1 7000000000$BINARY_MAIN_TOKEN --home $CHAIN_DIR/$CHAINID_1 --chain-id $CHAINID_1 --keyring-backend test
$BINARY_ICA_HOST gentx val2 7000000000stake --home $CHAIN_DIR/$CHAINID_2 --chain-id $CHAINID_2 --keyring-backend test
$BINARY collect-gentxs --home $CHAIN_DIR/$CHAINID_1
$BINARY_ICA_HOST collect-gentxs --home $CHAIN_DIR/$CHAINID_2

echo "Changing defaults and ports in app.toml and config.toml files..."
sed -i -e 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:'"$P2PPORT_1"'"#g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:'"$RPCPORT_1"'"#g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's/timeout_commit = "5s"/timeout_commit = "1s"/g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's/index_all_keys = false/index_all_keys = true/g' $CHAIN_DIR/$CHAINID_1/config/config.toml
sed -i -e 's/enable = false/enable = true/g' $CHAIN_DIR/$CHAINID_1/config/app.toml
sed -i -e 's/swagger = false/swagger = true/g' $CHAIN_DIR/$CHAINID_1/config/app.toml
sed -i -e 's#"tcp://0.0.0.0:1317"#"tcp://0.0.0.0:'"$RESTPORT_1"'"#g' $CHAIN_DIR/$CHAINID_1/config/app.toml
sed -i -e 's#":8080"#":'"$ROSETTA_1"'"#g' $CHAIN_DIR/$CHAINID_1/config/app.toml

sed -i -e 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:'"$P2PPORT_2"'"#g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:'"$RPCPORT_2"'"#g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's/timeout_commit = "5s"/timeout_commit = "1s"/g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's/index_all_keys = false/index_all_keys = true/g' $CHAIN_DIR/$CHAINID_2/config/config.toml
sed -i -e 's/enable = false/enable = true/g' $CHAIN_DIR/$CHAINID_2/config/app.toml
sed -i -e 's/swagger = false/swagger = true/g' $CHAIN_DIR/$CHAINID_2/config/app.toml
sed -i -e 's#"tcp://0.0.0.0:1317"#"tcp://0.0.0.0:'"$RESTPORT_2"'"#g' $CHAIN_DIR/$CHAINID_2/config/app.toml
sed -i -e 's#":8080"#":'"$ROSETTA_2"'"#g' $CHAIN_DIR/$CHAINID_2/config/app.toml

# change genesis.json
# CHAINID_1

# sed -i -e 's/minimum-gas-prices = ""/minimum-gas-prices = '\"0$BINARY_MAIN_TOKEN\"/'' $CHAIN_DIR/$CHAINID_1/config/app.toml;
# sed -i 's/mode = "full"/mode = "validator"/' $CHAIN_DIR/$CHAINID_1/config/config.toml;
sed -i -e 's/minimum-gas-prices = ""/minimum-gas-prices = "0stake"/' $CHAIN_DIR/$CHAINID_1/config/app.toml
# CHAINID_2
sed -i -e 's/minimum-gas-prices = ""/minimum-gas-prices = "0stake"/' $CHAIN_DIR/$CHAINID_2/config/app.toml

# Update host chain genesis to allow x/bank/MsgSend ICA tx execution
sed -i -e 's/\"allow_messages\": \[\]/"allow_messages": \["*"\] /' $CHAIN_DIR/$CHAINID_2/config/genesis.json
