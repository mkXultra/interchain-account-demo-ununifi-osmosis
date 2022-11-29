#!/bin/bash
set -e

# Load shell variables
. ./network/hermes/variables.sh

rm -rf ~/.hermes
### Sleep is needed otherwise the relayer crashes when trying to init
sleep 1
### Restore Keys
echo "alley afraid soup fall idea toss can goose become valve initial strong forward bright dish figure check leopard decide warfare hub unusual join cart" > mnemonic-file1.txt
$HERMES_BINARY --config ./network/hermes/config.toml keys add --chain test-1 --mnemonic-file mnemonic-file1.txt
# $HERMES_BINARY --config ./network/hermes/config.toml keys add test-1 --mnemonic-file "alley afraid soup fall idea toss can goose become valve initial strong forward bright dish figure check leopard decide warfare hub unusual join cart"
sleep 5

echo "record gift you once hip style during joke field prize dust unique length more pencil transfer quit train device arrive energy sort steak upset" > mnemonic-file2.txt
# $HERMES_BINARY --config ./network/hermes/config.toml keys add test-2 -m "record gift you once hip style during joke field prize dust unique length more pencil transfer quit train device arrive energy sort steak upset"
$HERMES_BINARY --config ./network/hermes/config.toml keys add --chain test-2 --mnemonic-file mnemonic-file2.txt
rm mnemonic-file1.txt
rm mnemonic-file2.txt
sleep 5
