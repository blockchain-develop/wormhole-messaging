// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "lib/wormhole-solidity-sdk/src/interfaces/IWormholeRelayer.sol";
import "lib/wormhole-solidity-sdk/src/interfaces/IWormholeReceiver.sol";
import "./../interfaces/IMessageWriter.sol";
import "./KeyStore.sol";

contract MessageReceiver is IWormholeReceiver {
    IWormholeRelayer public wormholeRelayer;
    IMessageWriter public messageWriter;
    address public registrationOwner;

    // Mapping to store registered senders for each chain
    mapping(uint16 => bytes32) public registeredSenders;

    event MessageReceived(
        uint16 sourceChain,
        bytes32 sourceAddress,
        uint256 message
    );

    //constructor(address _wormholeRelayer, address _messageWriter) {
    constructor(address _wormholeRelayer) {
        wormholeRelayer = IWormholeRelayer(_wormholeRelayer);
        //messageWriter = IMessageWriter(_messageWriter);
        messageWriter = new KeyStore();
        registrationOwner = msg.sender; // Set contract deployer as the owner
    }

    // Modifier to check if the sender is registered for the source chain
    modifier isRegisteredSender(uint16 sourceChain, bytes32 sourceAddress) {
        require(
            registeredSenders[sourceChain] == sourceAddress,
            "Not registered sender"
        );
        _;
    }

    // Function to register the valid sender address for a specific chain
    function setRegisteredSender(
        uint16 sourceChain,
        bytes32 sourceAddress
    ) public {
        require(
            msg.sender == registrationOwner,
            "Not allowed to set registered sender"
        );
        registeredSenders[sourceChain] = sourceAddress;
    }

    // Update receiveWormholeMessages to include the source address check
    function receiveWormholeMessages(
        bytes memory payload,
        bytes[] memory, // additional VAAs (optional, not needed here)
        bytes32 sourceAddress,
        uint16 sourceChain,
        bytes32 // delivery hash
    ) public payable override isRegisteredSender(sourceChain, sourceAddress) {
        require(
            msg.sender == address(wormholeRelayer),
            "Only the Wormhole relayer can call this function"
        );

        // Decode the payload to extract the message
        uint256 message = abi.decode(payload, (uint256));

        // Emit an event with the received message
        emit MessageReceived(sourceChain, sourceAddress, message);

        //
        messageWriter.setLatestStateRoot(message);
    }
}
