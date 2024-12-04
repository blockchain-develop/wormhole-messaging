// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8.18;

interface IMessageWriter {
    function setLatestStateRoot(uint256 stateRoot) external;
}
