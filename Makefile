-include .env

.PHONY: all clean build remove test 
#all targets in your Makefile which do not produce an output file with the same name as the target name should be PHONY.

all: clean remove install update build

clean :; rm -r build
#format :; movefmt
format :; aptos move fmt --config indent_size=2,tab_spaces=2
prove :; aptos move prove -f counter

build :; aptos move compile --named-addresses publisher=default
test :; aptos move test --named-addresses publisher=default
test_counter :; aptos move test -f counter --named-addresses publisher=default
test_vector :; aptos move test -f vector --named-addresses publisher=default
test_table :; aptos move test -f table --named-addresses publisher=default
test_reserve :; aptos move test -f reserve --named-addresses publisher=default
test_list :; aptos move test -f list --named-addresses publisher=default

deploy :; aptos move deploy #--named-addresses publisher=default
publish :; aptos move publish --named-addresses publisher=default # --skip-fetch-latest-git-deps

addItem :; aptos move run --function-id "0x_publisher_address::advanced_list::add_item"

getListCounter :; aptos move view --function-id "0x_publisher_address::advanced_list::get_list_counter" --args address:0x_publisher_address


#remove :; rm -rf .gitmodules

#ethereum_sepolia :; ${ETHEREUM_SEPOLIA_RPC}

env :; source .env