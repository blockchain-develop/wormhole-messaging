// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8.18;

interface IMessageReader {
    function getLatestStateRoot() external view returns (uint256);
}
