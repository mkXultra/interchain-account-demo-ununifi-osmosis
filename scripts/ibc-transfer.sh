export WALLET_1=$(ununifid keys show wallet1 -a --keyring-backend test --home ./data/test-1) && echo $WALLET_1;
export WALLET_2=$(ununifid keys show wallet2 -a --keyring-backend test --home ./data/test-1) && echo $WALLET_2;
export WALLET_3=$(osmosisd keys show wallet3 -a --keyring-backend test --home ./data/test-2) && echo $WALLET_3;
export WALLET_4=$(osmosisd keys show wallet4 -a --keyring-backend test --home ./data/test-2) && echo $WALLET_4;
export VAL2=$(osmosisd keys show val2 -a --keyring-backend test --home ./data/test-2) && echo $VAL2;

# send uguu to osmos chain
ununifid tx ibc-transfer transfer transfer channel-0 $VAL2 1000000uguu --from $WALLET_1 --chain-id test-1 --home ./data/test-1 --node tcp://localhost:16657 --keyring-backend test -y
# ununifid tx ibc-transfer transfer transfer channel-0 $WALLET_3 1000uguu --from $WALLET_1 --chain-id test-1 --home ./data/test-1 --node tcp://localhost:16657 --keyring-backend test -y

# check command
ununifid q bank balances $WALLET_1 --home ./data/test-1 --node tcp://localhost:16657
osmosisd q bank balances $WALLET_3 --home ./data/test-2 --node tcp://localhost:26657
osmosisd q bank balances $VAL2 --home ./data/test-2 --node tcp://localhost:26657


# send osmos stake to ununifi chain
# osmosisd tx ibc-transfer transfer transfer channel-0 $WALLET_1 1000stake --from $WALLET_3 --chain-id test-2 --home ./data/test-2 --node tcp://localhost:26657 --keyring-backend test -y
# osmosisd tx ibc-transfer transfer transfer channel-0 $WALLET_1 1000ibc/737D702F5E4DFE7A3A27DEEB16C5225C880F1A02AE637F67C194F9074BCD6ED8 --from $WALLET_3 --chain-id test-2 --home ./data/test-2 --node tcp://localhost:26657 --keyring-backend test -y


# ibc/737D702F5E4DFE7A3A27DEEB16C5225C880F1A02AE637F67C194F9074BCD6ED8
