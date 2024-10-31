-include .env

.PHONY: all clean build remove test 
#all targets in your Makefile which do not produce an output file with the same name as the target name should be PHONY.

all: clean remove install update build
balance :; aptos account balance
address :; aptos account lookup-address
list :; aptos account list

clean :; rm -r build
#format :; movefmt
fmt :; aptos move fmt --config indent_size=2,tab_spaces=2
prove :; aptos move prove -f counter

build :; aptos move compile --named-addresses publisher=default --skip-fetch-latest-git-deps
test :; aptos move test --named-addresses publisher=default
report :; aptos move test --coverage

test_counter :; aptos move test -f counter --named-addresses publisher=default
test_vector :; aptos move test -f vector --named-addresses publisher=default
test_table :; aptos move test -f table --named-addresses publisher=default
test_reserve :; aptos move test -f reserve --named-addresses publisher=default
test_list :; aptos move test -f list --named-addresses publisher=default
test_fungible_asset :; aptos move test -f fungible_asset --named-addresses publisher=default

publish :; aptos move publish --named-addresses publisher=default # --skip-fetch-latest-git-deps
# --save-metadata

publisher=0xde603e99e164aafa171f1d598473c5fa815d28d15df8934ac765137e536fb286
wallet1=0xa62889c74443d1a05af1472b581c138e3c28858eadfb5655a6216874d1b23ff4
mint :; aptos move run --function-id $(publisher)::fungible_asset::mint --args address:$(wallet1) u64:9000000000000000

addItem :; aptos move run --function-id "0x_publisher_address::advanced_list::add_item"

getListCounter :; aptos move view --function-id "0x_publisher_address::advanced_list::get_list_counter" --args address:0x_publisher_address


#remove :; rm -rf .gitmodules

#ethereum_sepolia :; ${ETHEREUM_SEPOLIA_RPC}

env :; source .env