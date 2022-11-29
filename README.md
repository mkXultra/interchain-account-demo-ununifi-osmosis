# Interchain Accounts

Developers integrating Interchain Accounts may choose to firstly enable host chain functionality, and add authentication modules later as desired.
Documentation regarding authentication modules can be found in the [IBC Developer Documentation](https://ibc.cosmos.network/main/apps/interchain-accounts/overview.html).

## Overview 

The following repository contains a basic example of an Interchain Accounts authentication module and serves as a developer guide for teams that wish to use interchain accounts functionality.

The Interchain Accounts module is now maintained within the `ibc-go` repository [here](https://github.com/cosmos/ibc-go/tree/main/modules/apps/27-interchain-accounts). 
Interchain Accounts is now available in the [`v3.0.0`](https://github.com/cosmos/ibc-go/releases/tag/v3.0.0) release of `ibc-go`.

### Developer Documentation

Interchain Accounts developer docs can be found on the IBC documentation website.

https://ibc.cosmos.network/main/apps/interchain-accounts/overview.html

## Setup

1. Download and install an IBC relayer. ([hermes](https://hermes.informal.systems/)
```bash
# hermes
cargo install --version 1.0.0 ibc-relayer-cli --bin hermes --locked

```

2. Bootstrap two chains, configure the relayer and create an IBC connection (on top of clients that are created as well)
```bash
# hermes
make init-hermes
```

3. Start the relayer
```bash
#hermes
make start-hermes
```

:exclamation: **NOTE:** It is abstracted away in the script files, but in case you want to manually run `rly start` with interchain accounts, you will need to add this flag: `-p events` to it.

> This is the situation *before* `make init-*`. The blockchains are not live yet.
![pre-init](./images/pre-init.png)

> This is the situation *after* `make init-*`. The chain binary's have been built and started, and an IBC connection between controller and host chains has been set up.
![post-init](./images/post-init.png)

## Demo

**NOTE:** For the purposes of this demo the setup scripts have been provided with a set of hardcoded mnemonics that generate deterministic wallet addresses used below.

```bash
# Store the following account addresses within the current shell env
export WALLET_1=$(ununifid keys show wallet1 -a --keyring-backend test --home ./data/test-1) && echo $WALLET_1;
export WALLET_2=$(ununifid keys show wallet2 -a --keyring-backend test --home ./data/test-1) && echo $WALLET_2;
export WALLET_3=$(osmosisd keys show wallet3 -a --keyring-backend test --home ./data/test-2) && echo $WALLET_3;
export WALLET_4=$(osmosisd keys show wallet4 -a --keyring-backend test --home ./data/test-2) && echo $WALLET_4;
```

### Registering an Interchain Account via IBC

Register an Interchain Account using the `intertx register` cmd. 
Here the message signer is used as the account owner.

```bash
# Register an interchain account on behalf of WALLET_1 where chain test-2 is the interchain accounts host
ununifid tx intertx register --from $WALLET_1 --connection-id connection-0 --chain-id test-1 --home ./data/test-1 --node tcp://localhost:16657 --keyring-backend test -y

# Query the address of the interchain account
ununifid query intertx interchainaccounts connection-0 $WALLET_1 --home ./data/test-1 --node tcp://localhost:16657

# Store the interchain account address by parsing the query result: cosmos1hd0f4u7zgptymmrn55h3hy20jv2u0ctdpq23cpe8m9pas8kzd87smtf8al
export ICA_ADDR=$(ununifid query intertx interchainaccounts connection-0 $WALLET_1 --home ./data/test-1 --node tcp://localhost:16657 -o json | jq -r '.interchain_account_address') && echo $ICA_ADDR
```

> This is the situation after registering the ICA. A channel has been created and an ICA has been registered on the host.
![post-register](./images/post-register.png)

#### Funding the Interchain Account wallet

Allocate funds to the new Interchain Account wallet by using the `bank send` cmd.
Note this is executed on the host chain to provide the account with an initial balance to execute transactions.

```bash
# Query the interchain account balance on the host chain. It should be empty.
ununifid q bank balances $ICA_ADDR --chain-id test-2 --node tcp://localhost:26657

# Send funds to the interchain account.
ununifid tx bank send $WALLET_3 $ICA_ADDR 10000stake --chain-id test-2 --home ./data/test-2 --node tcp://localhost:26657 --keyring-backend test -y

# Query the balance once again and observe the changes
ununifid q bank balances $ICA_ADDR --chain-id test-2 --node tcp://localhost:26657
```

> This is the situation after funding the ICA.
![post-fund](./images/post-fund.png)

#### Sending Interchain Account transactions

Send Interchain Accounts transactions using the `intertx submit` cmd. 
This command accepts a generic `sdk.Msg` JSON payload or path to JSON file as an arg.

- **Example 1:** Staking Delegation

```bash
# Output the host chain validator operator address: cosmosvaloper1qnk2n4nlkpw9xfqntladh74w6ujtulwnmxnh3k
cat ./data/test-2/config/genesis.json | jq -r '.app_state.genutil.gen_txs[0].body.messages[0].validator_address'

# Submit a staking delegation tx using the interchain account via ibc
ununifid tx intertx submit \
'{
    "@type":"/cosmos.staking.v1beta1.MsgDelegate",
    "delegator_address":"cosmos15ccshhmp0gsx29qpqq6g4zmltnnvgmyu9ueuadh9y2nc5zj0szls5gtddz",
    "validator_address":"cosmosvaloper1qnk2n4nlkpw9xfqntladh74w6ujtulwnmxnh3k",
    "amount": {
        "denom": "stake",
        "amount": "1000"
    }
}' --connection-id connection-0 --from $WALLET_1 --chain-id test-1 --home ./data/test-1 --node tcp://localhost:16657 --keyring-backend test -y

# Alternatively provide a path to a JSON file
ununifid tx intertx submit [path/to/msg.json] --connection-id connection-0 --from $WALLET_1 --chain-id test-1 --home ./data/test-1 --node tcp://localhost:16657 --keyring-backend test -y

# Wait until the relayer has relayed the packet

# Inspect the staking delegations on the host chain
ununifid q staking delegations-to cosmosvaloper1qnk2n4nlkpw9xfqntladh74w6ujtulwnmxnh3k --home ./data/test-2 --node tcp://localhost:26657
```

> This is the situation before after sending the staking tx. The user who is the owner of the ICA has staked funds on the host chain to a validator of choice through an interchain accounts packet.
![post-sendtx](./images/post-sendtx.png)

- **Example 2:** Bank Send

```bash
# Submit a bank send tx using the interchain account via ibc
ununifid tx intertx submit \
'{
    "@type":"/cosmos.bank.v1beta1.MsgSend",
    "from_address":"cosmos15ccshhmp0gsx29qpqq6g4zmltnnvgmyu9ueuadh9y2nc5zj0szls5gtddz",
    "to_address":"cosmos10h9stc5v6ntgeygf5xf945njqq5h32r53uquvw",
    "amount": [
        {
            "denom": "stake",
            "amount": "1000"
        }
    ]
}' --connection-id connection-0 --from $WALLET_1 --chain-id test-1 --home ./data/test-1 --node tcp://localhost:16657 --keyring-backend test -y

# Alternatively provide a path to a JSON file
ununifid tx intertx submit [path/to/msg.json] --connection-id connection-0 --from $WALLET_1 --chain-id test-1 --home ./data/test-1 --node tcp://localhost:16657 --keyring-backend test -y

# Wait until the relayer has relayed the packet

# Query the interchain account balance on the host chain
ununifid q bank balances $ICA_ADDR --chain-id test-2 --node tcp://localhost:26657
```

#### Testing timeout scenario

1. Stop the relayer process and send an interchain accounts transaction using one of the examples provided above.

2. Wait for approx. 1 minute for the timeout to elapse.

3. Restart the relayer process

```bash
#hermes
make start-hermes

#go relayer
make start-golang-rly
```

4. Observe the packet timeout and relayer reacting appropriately (issuing a MsgTimeout to testchain `test-1`).

5. Due to the nature of ordered channels, the timeout will subsequently update the state of the channel to `STATE_CLOSED`.
Observe both channel ends by querying the IBC channels for each node.

```bash
# inspect channel ends on test chain 1
ununifid q ibc channel channels --home ./data/test-1 --node tcp://localhost:16657

# inspect channel ends on test chain 2
ununifid q ibc channel channels --home ./data/test-2 --node tcp://localhost:26657
```

6. Open a new channel for the existing interchain account on the same connection.

```bash
ununifid tx intertx register --from $WALLET_1 --connection-id connection-0 --chain-id test-1 --home ./data/test-1 --node tcp://localhost:16657 --keyring-backend test -y
```

7. Inspect the IBC channels once again and observe a new creately interchain accounts channel with `STATE_OPEN`.

```bash
# inspect channel ends on test chain 1
ununifid q ibc channel channels --home ./data/test-1 --node tcp://localhost:16657

# inspect channel ends on test chain 2
ununifid q ibc channel channels --home ./data/test-2 --node tcp://localhost:26657
```

## Collaboration

Please use conventional commits  https://www.conventionalcommits.org/en/v1.0.0/

```
chore(bump): bumping version to 2.0
fix(bug): fixing issue with...
feat(featurex): adding feature...
```
