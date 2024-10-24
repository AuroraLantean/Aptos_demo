-include .env

.PHONY: all clean build remove prove test 
#all targets in your Makefile which do not produce an output file with the same name as the target name should be PHONY.

all: clean remove install update build

clean :; rm -r build
#format :; movefmt
format :; aptos move fmt --config indent_size=2,tab_spaces=2
prove :; aptos move prove
build :; aptos move compile --named-addresses publisher=default
test :; aptos move test --named-addresses publisher=default
test4 :; aptos move test -f reserve --named-addresses publisher=default
test3 :; aptos move test -f list --named-addresses publisher=default
publish :; aptos move publish --named-addresses publisher=default

addItem :; aptos move run --function-id "0x_publisher_address::advanced_list::add_item"

getListCounter :; aptos move view --function-id "0x_publisher_address::advanced_list::get_list_counter" --args address:0x_publisher_address


prove :; aptos move prove --named-addresses publisher=default

#remove :; rm -rf .gitmodules

#ethereum_sepolia :; ${ETHEREUM_SEPOLIA_RPC}

env :; source .env