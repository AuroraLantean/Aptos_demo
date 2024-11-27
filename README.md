# Aptos Demo

## Why Aptos? Comparison between Aptos and Solana
https://learn.aptoslabs.com/en/tutorials/solana-to-aptos-guide/cheat-sheet?workshop=solana-to-aptos

#### Resource-oriented Move language
Move is designed specifically for writing smart contracts on blockchain, using a resource-oriented programming model with linear types, making sure each resource cannot be used in multiple places at the same time.

#### Optimistic Parallelism
This is one of the most important differences between Solana and Aptos. 
On Solana, developers need to explicitly declare all the accounts that will be written to in the transaction. This is a huge burden for developers.

On Aptos, the runtime will automatically detect the accounts that are written to on the fly. 


## Installation 
#### Install Aptos CLI v4.4.0
https://aptos.dev/en/build/cli/install-cli/install-cli-linux

`aptos update aptos && aptos update movefmt`
OR
`curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3`
Then: `aptos --version`

Install Move Prover
According to https://aptos.dev/en/build/cli/setup-cli/install-move-prover

Install Aptos CLI for Linux: `curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3`

Download Aptos core from https://github.com/aptos-labs/aptos-core

cd into the downloaded Aptos core
`./scripts/dev_setup.sh -yp`

if it says `error: externally-managed-environment`, ignore it...

Then run the Move Prover:
`aptos move prove --named-addresses publisher=default`

## Setup Account
make a new CLI account: `aptos init`, which will generate a `.aptos` folder with config.yaml file. That yaml file contains your CLI private_key, public_key, and account. 

Get some Testnet/Devnet Aptos via faucets:
https://www.aptosfaucet.com/

Explorer: https://explorer.aptoslabs.com

After deploying/publishing your modules, go to https://explorer.aptoslabs.com/account/YOUR_CLI_WALLET , click on "modules" and click on the module you want on the left hand side.

Deployment on Devnet: https://explorer.aptoslabs.com/account/0xde603e99e164aafa171f1d598473c5fa815d28d15df8934ac765137e536fb286/modules/code/fungible_asset?network=devnet


## Test
```
	make test1
	make test2
	make test3
	make test4
```

## NFT
https://aptos.dev/en/build/guides/your-first-nft
```
git clone https://github.com/aptos-labs/aptos-ts-sdk.git
cd aptos-ts-sdk
pnpm install
pnpm build

cd examples/typescript-esm
pnpm install
pnpm build
pnpm run simple_digital_asset
```
https://github.com/aptos-labs/aptos-ts-sdk/blob/main/examples/typescript-esm/simple_digital_asset.ts

