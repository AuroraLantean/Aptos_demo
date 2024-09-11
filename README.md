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
#### Install Aptos CLI
https://aptos.dev/en/build/cli/install-cli/install-cli-linux

`aptos update`
OR
`curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3`
Then: `aptos --version`

## Test
```
	aptos move test
```