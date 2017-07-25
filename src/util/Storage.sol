pragma solidity ^0.4.13;


/// @title Storage
/// @author Eliott Teissonniere
contract Storage {
    mapping (bytes32 => uint256) uintStorage;

    function setStorage(bytes32 key, uint256 value) internal {
        uintStorage[key] = value;
    }

    function getStorage(bytes32 key) internal returns (uint256 value) {
        value = uintStorage[key];
    }
}
