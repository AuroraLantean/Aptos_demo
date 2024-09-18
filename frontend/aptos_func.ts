import { Aptos, AptosConfig, Network, Account } from "@aptos-labs/ts-sdk";

export const config = new AptosConfig({
	network: Network.TESTNET,
});
export const aptos = new Aptos(config);
export const rawTxn = await aptos.transaction.build.simple({
	sender: sender.accountAddress,
	data: {
		function: `${MODULE_ADDRESS}::${MODULE_NAME}::create_todo_list`,
		// sender will be automatically passed as the signer
		functionArguments: [],
	},
});
export const pendingTxn = await aptos.signAndSubmitTransaction({
	signer: sender,
	transaction: rawTxn,
});
export const response = await aptos
	.waitForTransaction({
		transactionHash: pendingTxn.hash,
	})
	.then((response) => {
		console.log(response);
	});

export const getTodoList = async (
	MODULE_ADDRESS: string,
	MODULE_NAME: string,
	userAddress: string,
) => {
	// call view function off-chain
	const [owner, todosCount] = await aptos.view({
		payload: {
			function: `${MODULE_ADDRESS}::${MODULE_NAME}::get_todo_list`,
			typeArguments: [],
			functionArguments: [userAddress],
		},
	});
	console.log(owner);
	console.log(todosCount);
};
