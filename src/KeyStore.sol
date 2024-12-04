// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "lib/wormhole-solidity-sdk/src/interfaces/IWormholeRelayer.sol";
import "./../interfaces/IMessageWriter.sol";
import "./RingBuffer.sol";

contract KeyStore is IMessageWriter {
    address public writer;

    /// @notice The latest KeyStore root.
    uint256 public root;

    /// @notice The 10 latest KeyStore roots.
    RingBuffer10 public roots;

    event RootUpdated(uint256 indexed root);

    constructor() {
        writer = msg.sender;
    }

    // Modifier to check if the sender is registered for the source chain
    modifier isWriter(address addr) {
        require(addr == writer, "Not writer");
        _;
    }

    function setWriter(address _writer) public isWriter(msg.sender) {
        writer = _writer;
    }

    function setLatestStateRoot(
        uint256 stateRoot
    ) external isWriter(msg.sender) {
        // Update the root.
        root = stateRoot;
        roots.append(stateRoot);

        emit RootUpdated(stateRoot);
    }

    function getLatestStateRoot() public view returns (uint256 stateRoot) {
        return root;
    }
}
