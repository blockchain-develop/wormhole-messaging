// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "lib/wormhole-solidity-sdk/src/interfaces/IWormholeRelayer.sol";
import "./../interfaces/IMessageReader.sol";

contract MessageSender {
    IWormholeRelayer public wormholeRelayer;
    IMessageReader public messageReader;
    uint256 constant GAS_LIMIT = 100000; // Adjust the gas limit as needed

    event MessageSend(
        uint16 targetChain,
        address targetAddress,
        uint256 message
    );

    constructor(address _wormholeRelayer, address _messageReader) {
        wormholeRelayer = IWormholeRelayer(_wormholeRelayer);
        messageReader = IMessageReader(_messageReader);
    }

    function quoteCrossChainCost(
        uint16 targetChain
    ) public view returns (uint256 cost) {
        (cost, ) = wormholeRelayer.quoteEVMDeliveryPrice(
            targetChain,
            0,
            GAS_LIMIT
        );
    }

    function sendMessage(
        uint16 targetChain,
        address targetAddress
    ) external payable {
        uint256 cost = quoteCrossChainCost(targetChain); // Dynamically calculate the cross-chain cost
        require(
            msg.value >= cost,
            "Insufficient funds for cross-chain delivery"
        );

        uint256 message = messageReader.getLatestStateRoot();

        wormholeRelayer.sendPayloadToEvm{value: cost}(
            targetChain,
            targetAddress,
            abi.encode(message, msg.sender), // Payload contains the message and sender address
            0, // No receiver value needed
            GAS_LIMIT // Gas limit for the transaction
        );

        // Emit an event with the received message
        emit MessageSend(targetChain, targetAddress, message);
    }
}
