const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function main() {
	// Load the chain configuration from the JSON file
	const chains = JSON.parse(
		fs.readFileSync(path.resolve(__dirname, '../deploy-config/chains.json'))
	);

	// Get the Celo Testnet configuration
	const ethereumChain = chains.chains.find((chain) => chain.description.includes('Ethereum Sepolia'));

	// Set up the provider and wallet
	const provider = new ethers.JsonRpcProvider(ethereumChain.rpc);
	const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

	// Load the ABI and bytecode of the MessageReceiver contract
	const keyStoreJson = JSON.parse(
		fs.readFileSync(
			path.resolve(__dirname, '../out/KeyStore.sol/KeyStore.json'),
			'utf8'
		)
	);

	const abi = keyStoreJson.abi;
	const bytecode = keyStoreJson.bytecode;

	// Create a ContractFactory for MessageReceiver
	const KeyStore = new ethers.ContractFactory(abi, bytecode, wallet);

	// Deploy the contract using the Wormhole Relayer address for Celo Testnet
	const keyStoreContract = await KeyStore.deploy();
	await keyStoreContract.waitForDeployment();

	console.log('KeyStore deployed to:', keyStoreContract.target); // `target` is the contract address in ethers.js v6

	// Update the deployedContracts.json file
	const deployedContractsPath = path.resolve(__dirname, '../deploy-config/deployedContracts.json');
	const deployedContracts = JSON.parse(fs.readFileSync(deployedContractsPath, 'utf8'));

	deployedContracts.ethereum = {
		KeyStore: keyStoreContract.target,
		deployedAt: new Date().toISOString(),
	};

	fs.writeFileSync(deployedContractsPath, JSON.stringify(deployedContracts, null, 2));
}

main().catch((error) => {
	console.error(error);
	process.exit(1);
});
