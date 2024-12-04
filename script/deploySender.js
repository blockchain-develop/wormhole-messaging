const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");
require("dotenv").config();

async function main() {
  // Load the chain configuration from JSON
  const chains = JSON.parse(
    fs.readFileSync(path.resolve(__dirname, "../deploy-config/chains.json"))
  );

  // Get the Ethereum Sepolia configuration
  const ethereumChain = chains.chains.find((chain) =>
    chain.description.includes("Ethereum Sepolia")
  );

  // Set up the provider and wallet
  const provider = new ethers.JsonRpcProvider(ethereumChain.rpc);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  // Load the ABI and bytecode of the MessageSender contract
  const messageSenderJson = JSON.parse(
    fs.readFileSync(path.resolve(__dirname, "../out/MessageSender.sol/MessageSender.json"), "utf8")
  );

  const abi = messageSenderJson.abi;
  const bytecode = messageSenderJson.bytecode;

  // Create a ContractFactory for MessageSender
  const MessageSender = new ethers.ContractFactory(abi, bytecode, wallet);

  // Update the deployedContracts.json file
  const deployedContractsPath = path.resolve(__dirname, "../deploy-config/deployedContracts.json");
  const deployedContracts = JSON.parse(fs.readFileSync(deployedContractsPath, "utf8"));

  const keyStoreAddress = deployedContracts.ethereum.KeyStore;

  // Deploy the contract using the Wormhole Relayer address for Avalanche Fuji
  const senderContract = await MessageSender.deploy(ethereumChain.wormholeRelayer, keyStoreAddress);
  await senderContract.waitForDeployment();

  console.log("MessageSender deployed to:", senderContract.target);

  deployedContracts.ethereum = {
    MessageSender: senderContract.target,
    KeyStore: deployedContracts.ethereum.KeyStore,
    deployedAt: new Date().toISOString()
  };

  fs.writeFileSync(deployedContractsPath, JSON.stringify(deployedContracts, null, 2));
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
