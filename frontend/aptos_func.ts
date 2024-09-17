import { Aptos, AptosConfig, Network, Account } from "@aptos-labs/ts-sdk";
const config = new AptosConfig({
  network: Network.TESTNET,
});
const aptos = new Aptos(config);
const rawTxn = await aptos.transaction.build.simple({
  sender: sender.accountAddress,
  data: {
    function: `${MODULE_ADDRESS}::${MODULE_NAME}::create_todo_list`,
    // sender will be automatically passed as the signer
    functionArguments: [],
  },
});
const pendingTxn = await aptos.signAndSubmitTransaction({
  signer: sender,
  transaction: rawTxn,
});
const response = await aptos
  .waitForTransaction({
    transactionHash: pendingTxn.hash,
  })
  .then((response) => {
    console.log(response);
  });
