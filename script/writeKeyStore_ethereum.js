const { ethers } = require('ethers');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function main() {
	// Load the chain configuration and deployed contract addresses
	const chains = JSON.parse(
		fs.readFileSync(path.resolve(__dirname, '../deploy-config/chains.json'))
	);
	const deployedContracts = JSON.parse(
		fs.readFileSync(path.resolve(__dirname, '../deploy-config/deployedContracts.json'))
	);

	console.log('KeyStore Contract Address: ', deployedContracts.ethereum.KeyStore);
	console.log('...');

	// Get the Avalanche Fuji configuration
	const ethereumChain = chains.chains.find((chain) =>
		chain.description.includes('Ethereum Sepolia')
	);

	// Set up the provider and wallet
	const provider = new ethers.JsonRpcProvider(ethereumChain.rpc);
	const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

	// Load the ABI of the MessageSender contract
	const keyStoreJson = JSON.parse(
		fs.readFileSync(path.resolve(__dirname, '../out/KeyStore.sol/KeyStore.json'), 'utf8')
	);

	// Create a contract instance for MessageSender
	const KeyStore = new ethers.Contract(
		deployedContracts.ethereum.KeyStore, // Automatically use the deployed address
		keyStoreJson.abi,
		wallet
	);

	const currentStateRoot = await KeyStore.getLatestStateRoot();
	console.log('current state root: ', currentStateRoot);

	// Send the message (make sure to send enough gas in the transaction)
	const message = 1;
	const tx = await KeyStore.setLatestStateRoot(message);

	console.log('Transaction sent, waiting for confirmation...');
	await tx.wait();
	console.log('...');

	console.log('Message sent! Transaction hash:', tx.hash);


	const newStateRoot = await KeyStore.getLatestStateRoot();
	console.log('new state root: ', newStateRoot);
}

main().catch((error) => {
	console.error(error);
	process.exit(1);
});
